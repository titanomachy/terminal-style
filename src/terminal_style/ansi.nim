## ANSI escape-sequence tokenization and composition.
##
## The tokenizer recognizes complete CSI sequences (including SGR colors), OSC
## sequences terminated by BEL or ST, and two-byte escape sequences. Incomplete
## or malformed escapes are returned as ordinary text instead of silently
## consuming the remainder of a log line.

type
  AnsiTokenKind* = enum
    ## The kind of a token returned by ``tokenizeAnsi``.
    atkText,
    atkCsi,
    atkOsc,
    atkEscape

  AnsiToken* = object
    ## One lossless token from an ANSI-bearing string.
    kind*: AnsiTokenKind
    value*: string

const
  ansiEscape* = '\e'
  ansiReset* = "\e[0m"

proc addToken(tokens: var seq[AnsiToken]; kind: AnsiTokenKind;
              value: string) =
  if value.len == 0:
    return
  if kind == atkText and tokens.len > 0 and tokens[^1].kind == atkText:
    tokens[^1].value.add value
  else:
    tokens.add AnsiToken(kind: kind, value: value)

proc tokenizeAnsi*(value: string): seq[AnsiToken] =
  ## Splits ``value`` without losing any bytes. Only complete ANSI sequences
  ## become control tokens; malformed or unterminated sequences remain text.
  var
    index = 0
    textStart = 0

  template flushText(untilIndex: int) =
    if untilIndex > textStart:
      result.addToken(atkText, value[textStart ..< untilIndex])

  while index < value.len:
    if value[index] != ansiEscape:
      inc index
      continue

    flushText(index)
    let escapeStart = index
    if index + 1 >= value.len:
      result.addToken(atkText, $ansiEscape)
      inc index
      textStart = index
      continue

    case value[index + 1]
    of '[':
      index += 2
      var complete = false
      while index < value.len:
        let byte = ord(value[index])
        if byte >= 0x40 and byte <= 0x7e:
          inc index
          complete = true
          break
        if byte < 0x20 or byte > 0x3f:
          break
        inc index
      if complete:
        result.addToken(atkCsi, value[escapeStart ..< index])
      else:
        # Preserve only the introducer as text, then scan the remaining bytes
        # normally so a later valid escape can still be recognized.
        result.addToken(atkText, value[escapeStart .. escapeStart + 1])
        index = escapeStart + 2
    of ']':
      index += 2
      var complete = false
      while index < value.len:
        if value[index] == '\a':
          inc index
          complete = true
          break
        if value[index] == ansiEscape and index + 1 < value.len and
            value[index + 1] == '\\':
          index += 2
          complete = true
          break
        inc index
      if complete:
        result.addToken(atkOsc, value[escapeStart ..< index])
      else:
        result.addToken(atkText, value[escapeStart .. escapeStart + 1])
        index = escapeStart + 2
    else:
      let second = ord(value[index + 1])
      if second >= 0x30 and second <= 0x7e:
        index += 2
        result.addToken(atkEscape, value[escapeStart ..< index])
      else:
        result.addToken(atkText, $ansiEscape)
        inc index
    textStart = index

  flushText(value.len)

proc stripAnsi*(value: string): string =
  ## Removes complete ANSI control sequences. Malformed sequences are retained
  ## verbatim, making the operation safe for arbitrary application input.
  for token in tokenizeAnsi(value):
    if token.kind == atkText:
      result.add token.value

proc isSgrReset(sequence: string): bool =
  if sequence.len < 3 or sequence[^1] != 'm':
    return false
  let parameters = sequence[2 ..< sequence.high]
  if parameters.len == 0:
    return true
  var start = 0
  for index in 0 .. parameters.len:
    if index == parameters.len or parameters[index] == ';':
      let parameter = parameters[start ..< index]
      if parameter.len == 0 or parameter == "0":
        return true
      start = index + 1

proc composeAnsi*(opening, value: string; enabled = true): string =
  ## Wraps ``value`` in an SGR ``opening`` sequence. When nested content resets
  ## its style, the outer sequence is reapplied. With ``enabled = false`` all
  ## complete ANSI controls in ``value`` are removed.
  if not enabled:
    return stripAnsi(value)
  if opening.len == 0:
    return value

  result = opening
  for token in tokenizeAnsi(value):
    result.add token.value
    if token.kind == atkCsi and token.value.isSgrReset:
      result.add opening
  result.add ansiReset
