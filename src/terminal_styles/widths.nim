## ANSI-aware terminal-cell measurement and layout.
##
## Terminal width differs from UTF-8 byte length and Unicode rune count. These
## helpers treat combining marks and joiners as zero-width, common East Asian
## and emoji characters as two cells, and joined emoji as one grapheme.

import std/[strutils, unicode]

import ./ansi

export ansi

type
  TextAlignment* = enum
    ## Horizontal alignment used by ``padAnsi``.
    alignLeft,
    alignCenter,
    alignRight

  WrapMode* = enum
    ## Line-breaking strategy used by ``wrapAnsi``.
    wrapWords,
    wrapCharacters

  StyledUnit = object
    raw: string
    width: int
    newline: bool
    whitespace: bool
    regionalCount: int
    joinNext: bool

  AnsiState = object
    sgr: string
    hyperlink: string

proc inRange(value, first, last: int): bool {.inline.} =
  value >= first and value <= last

proc isCombining(value: int): bool =
  # Includes combining scripts, variation selectors, and emoji modifiers.
  result =
    value.inRange(0x0300, 0x036f) or value.inRange(0x0483, 0x0489) or
    value.inRange(0x0591, 0x05bd) or value == 0x05bf or
    value.inRange(0x05c1, 0x05c2) or value.inRange(0x05c4, 0x05c5) or
    value == 0x05c7 or value.inRange(0x0610, 0x061a) or
    value.inRange(0x064b, 0x065f) or value == 0x0670 or
    value.inRange(0x06d6, 0x06ed) or value.inRange(0x0711, 0x0711) or
    value.inRange(0x0730, 0x074a) or value.inRange(0x07a6, 0x07b0) or
    value.inRange(0x07eb, 0x07f3) or value.inRange(0x0816, 0x082d) or
    value.inRange(0x0859, 0x085b) or value.inRange(0x08d3, 0x0903) or
    value.inRange(0x093a, 0x094f) or value.inRange(0x0951, 0x0957) or
    value.inRange(0x0962, 0x0963) or value.inRange(0x0981, 0x0983) or
    value.inRange(0x09bc, 0x09cd) or value == 0x09d7 or
    value.inRange(0x09e2, 0x09e3) or value.inRange(0x0a01, 0x0a03) or
    value.inRange(0x0a3c, 0x0a51) or value.inRange(0x0a70, 0x0a71) or
    value == 0x0a75 or value.inRange(0x0a81, 0x0a83) or
    value.inRange(0x0abc, 0x0acd) or value.inRange(0x0ae2, 0x0ae3) or
    value.inRange(0x0b01, 0x0b03) or value.inRange(0x0b3c, 0x0b57) or
    value.inRange(0x0b62, 0x0b63) or value == 0x0b82 or
    value.inRange(0x0bbe, 0x0bcd) or value == 0x0bd7 or
    value.inRange(0x0c00, 0x0c04) or value.inRange(0x0c3e, 0x0c56) or
    value.inRange(0x0c62, 0x0c63) or value.inRange(0x0c81, 0x0c83) or
    value.inRange(0x0cbc, 0x0cd6) or value.inRange(0x0ce2, 0x0ce3) or
    value.inRange(0x0d00, 0x0d03) or value.inRange(0x0d3b, 0x0d4d) or
    value == 0x0d57 or value.inRange(0x0d62, 0x0d63) or
    value.inRange(0x0d81, 0x0d83) or value.inRange(0x0dca, 0x0df3) or
    value.inRange(0x0e31, 0x0e4e) or value.inRange(0x0eb1, 0x0ecd) or
    value.inRange(0x0f18, 0x0f19) or value.inRange(0x0f35, 0x0f39) or
    value.inRange(0x0f71, 0x0f84) or value.inRange(0x0f86, 0x0f87) or
    value.inRange(0x0f8d, 0x0fbc) or value.inRange(0x102b, 0x103e) or
    value.inRange(0x1056, 0x1059) or value.inRange(0x105e, 0x1060) or
    value.inRange(0x1062, 0x1064) or value.inRange(0x1067, 0x106d) or
    value.inRange(0x1071, 0x1074) or value.inRange(0x1082, 0x108d) or
    value.inRange(0x109a, 0x109d) or value.inRange(0x135d, 0x135f) or
    value.inRange(0x1712, 0x1715) or value.inRange(0x1732, 0x1734) or
    value.inRange(0x1752, 0x1753) or value.inRange(0x1772, 0x1773) or
    value.inRange(0x17b4, 0x17d3) or value == 0x17dd or
    value.inRange(0x180b, 0x180f) or value.inRange(0x1885, 0x1886) or
    value == 0x18a9 or value.inRange(0x1920, 0x192b) or
    value.inRange(0x1930, 0x193b) or value.inRange(0x1a17, 0x1a1b) or
    value.inRange(0x1a55, 0x1a7f) or value.inRange(0x1ab0, 0x1ace) or
    value.inRange(0x1b00, 0x1b44) or value.inRange(0x1b6b, 0x1b73) or
    value.inRange(0x1b80, 0x1baa) or value.inRange(0x1be6, 0x1bf3) or
    value.inRange(0x1c24, 0x1c37) or value.inRange(0x1cd0, 0x1cf9) or
    value.inRange(0x1dc0, 0x1dff) or value.inRange(0x20d0, 0x20f0) or
    value.inRange(0x2cef, 0x2cf1) or value == 0x2d7f or
    value.inRange(0x2de0, 0x2dff) or value.inRange(0x302a, 0x302f) or
    value.inRange(0x3099, 0x309a) or value.inRange(0xa66f, 0xa672) or
    value.inRange(0xa674, 0xa67d) or value.inRange(0xa69e, 0xa69f) or
    value.inRange(0xa6f0, 0xa6f1) or value.inRange(0xa802, 0xa802) or
    value.inRange(0xa806, 0xa806) or value.inRange(0xa80b, 0xa80b) or
    value.inRange(0xa823, 0xa827) or value.inRange(0xa880, 0xa881) or
    value.inRange(0xa8b4, 0xa8c5) or value.inRange(0xa8e0, 0xa8f1) or
    value == 0xa8ff or value.inRange(0xa926, 0xa92d) or
    value.inRange(0xa947, 0xa953) or value.inRange(0xa980, 0xa983) or
    value.inRange(0xa9b3, 0xa9c0) or value == 0xa9e5 or
    value.inRange(0xaa29, 0xaa36) or value == 0xaa43 or
    value.inRange(0xaa4c, 0xaa4d) or value.inRange(0xaa7b, 0xaa7d) or
    value == 0xaab0 or value.inRange(0xaab2, 0xaab4) or
    value.inRange(0xaab7, 0xaab8) or value.inRange(0xaabe, 0xaabf) or
    value == 0xaac1 or value.inRange(0xaaeb, 0xaaef) or
    value.inRange(0xaaf5, 0xaaf6) or value.inRange(0xabe3, 0xabea) or
    value.inRange(0xabec, 0xabed) or value == 0xfb1e or
    value.inRange(0xfe00, 0xfe0f) or value.inRange(0xfe20, 0xfe2f) or
    value == 0x101fd or value == 0x102e0 or
    value.inRange(0x10376, 0x1037a) or value.inRange(0x10a01, 0x10a0f) or
    value.inRange(0x10a38, 0x10a3f) or value.inRange(0x10ae5, 0x10ae6) or
    value.inRange(0x11000, 0x11002) or value.inRange(0x11038, 0x11046) or
    value.inRange(0x1107f, 0x11082) or value.inRange(0x110b0, 0x110ba) or
    value.inRange(0x11100, 0x11102) or value.inRange(0x11127, 0x11134) or
    value.inRange(0x11145, 0x11146) or value == 0x11173 or
    value.inRange(0x11180, 0x111c0) or value.inRange(0x111c9, 0x111cc) or
    value.inRange(0x1122c, 0x11237) or value == 0x1123e or
    value.inRange(0x112df, 0x112ea) or value.inRange(0x11300, 0x11303) or
    value.inRange(0x1133b, 0x1134d) or value == 0x11357 or
    value.inRange(0x11362, 0x11374) or value.inRange(0x11435, 0x11446) or
    value.inRange(0x114b0, 0x114c3) or value.inRange(0x115af, 0x115c0) or
    value.inRange(0x11630, 0x11640) or value.inRange(0x116ab, 0x116b7) or
    value.inRange(0x1171d, 0x1172b) or value.inRange(0x1182c, 0x1183a) or
    value.inRange(0x11930, 0x11943) or value.inRange(0x119d1, 0x119e4) or
    value.inRange(0x11a01, 0x11a0a) or value.inRange(0x11a33, 0x11a39) or
    value.inRange(0x11a51, 0x11a5b) or value.inRange(0x11a8a, 0x11a99) or
    value.inRange(0x11c2f, 0x11c3f) or value.inRange(0x11cb0, 0x11cb6) or
    value.inRange(0x11d31, 0x11d47) or value.inRange(0x11d8a, 0x11d97) or
    value.inRange(0x11ef3, 0x11ef6) or value.inRange(0x16af0, 0x16af4) or
    value.inRange(0x16b30, 0x16b36) or value.inRange(0x16f4f, 0x16f87) or
    value.inRange(0x16f8f, 0x16f92) or value.inRange(0x1bc9d, 0x1bc9e) or
    value.inRange(0x1d165, 0x1d169) or value.inRange(0x1d16d, 0x1d182) or
    value.inRange(0x1d185, 0x1d18b) or value.inRange(0x1d1aa, 0x1d1ad) or
    value.inRange(0x1d242, 0x1d244) or value.inRange(0x1da00, 0x1da36) or
    value.inRange(0x1da3b, 0x1da6c) or value == 0x1da75 or
    value == 0x1da84 or value.inRange(0x1da9b, 0x1daaf) or
    value.inRange(0x1e000, 0x1e02a) or value.inRange(0x1e130, 0x1e136) or
    value == 0x1e2ae or value.inRange(0x1e2ec, 0x1e2ef) or
    value.inRange(0x1e8d0, 0x1e8d6) or value.inRange(0x1e944, 0x1e94a) or
    value.inRange(0x1f3fb, 0x1f3ff) or value.inRange(0xe0100, 0xe01ef)

proc isWide(value: int): bool =
  result = value.inRange(0x1100, 0x115f) or value.inRange(0x231a, 0x231b) or
    value.inRange(0x2329, 0x232a) or value.inRange(0x23e9, 0x23ec) or
    value == 0x23f0 or value == 0x23f3 or value.inRange(0x25fd, 0x25fe) or
    value.inRange(0x2614, 0x2615) or value.inRange(0x2648, 0x2653) or
    value == 0x267f or value == 0x2693 or value == 0x26a1 or
    value.inRange(0x26aa, 0x26ab) or value.inRange(0x26bd, 0x26be) or
    value.inRange(0x26c4, 0x26c5) or value == 0x26ce or value == 0x26d4 or
    value == 0x26ea or value.inRange(0x26f2, 0x26f3) or value == 0x26f5 or
    value == 0x26fa or value == 0x26fd or value == 0x2705 or
    value.inRange(0x270a, 0x270b) or value == 0x2728 or value == 0x274c or
    value == 0x274e or value.inRange(0x2753, 0x2755) or value == 0x2757 or
    value.inRange(0x2795, 0x2797) or value == 0x27b0 or value == 0x27bf or
    value.inRange(0x2b1b, 0x2b1c) or value == 0x2b50 or value == 0x2b55 or
    value.inRange(0x2e80, 0x303e) or value.inRange(0x3040, 0xa4cf) or
    value.inRange(0xac00, 0xd7a3) or value.inRange(0xf900, 0xfaff) or
    value.inRange(0xfe10, 0xfe19) or value.inRange(0xfe30, 0xfe6f) or
    value.inRange(0xff00, 0xff60) or value.inRange(0xffe0, 0xffe6) or
    value.inRange(0x1f000, 0x1faff) or value.inRange(0x20000, 0x3fffd)

proc runeCellWidth(value: int): int =
  if value == 0 or value < 0x20 or value.inRange(0x7f, 0x9f) or
      value == 0x200d or value.isCombining:
    0
  elif value.isWide:
    2
  else:
    1

proc units(value: string): tuple[items: seq[StyledUnit], trailing: string] =
  var pending: string
  for token in tokenizeAnsi(value):
    if token.kind != atkText:
      pending.add token.value
      continue
    var index = 0
    while index < token.value.len:
      let
        size = runeLenAt(token.value, index)
        runeText = token.value[index ..< index + size]
        codepoint = int(runeAt(token.value, index))
      index += size
      if codepoint == 0x0a:
        result.items.add StyledUnit(raw: pending & runeText, newline: true)
        pending.setLen(0)
        continue
      if codepoint == 0x0d and index < token.value.len and
          token.value[index] == '\n':
        continue

      let combining = codepoint.isCombining or codepoint == 0x200d
      if result.items.len > 0 and not result.items[^1].newline and
          (combining or result.items[^1].joinNext or
           (codepoint.inRange(0x1f1e6, 0x1f1ff) and
            result.items[^1].regionalCount == 1)):
        result.items[^1].raw.add pending & runeText
        pending.setLen(0)
        if codepoint == 0x200d:
          result.items[^1].joinNext = true
        elif result.items[^1].joinNext:
          result.items[^1].joinNext = false
          result.items[^1].width = max(result.items[^1].width,
            runeCellWidth(codepoint))
        elif codepoint == 0xfe0f or codepoint == 0x20e3:
          result.items[^1].width = max(result.items[^1].width, 2)
        elif codepoint.inRange(0x1f1e6, 0x1f1ff):
          inc result.items[^1].regionalCount
        continue

      result.items.add StyledUnit(raw: pending & runeText,
        width: runeCellWidth(codepoint),
        whitespace: codepoint == 0x20 or codepoint == 0x09,
        regionalCount: (if codepoint.inRange(0x1f1e6, 0x1f1ff): 1 else: 0))
      pending.setLen(0)
  result.trailing = pending

proc updateState(state: var AnsiState; raw: string) =
  for token in tokenizeAnsi(raw):
    case token.kind
    of atkCsi:
      if token.value[^1] == 'm':
        let params = token.value[2 ..< token.value.high]
        if params.len == 0 or params == "0" or params.startsWith("0;") or
            params.contains(";0;") or params.endsWith(";0"):
          state.sgr.setLen(0)
        else:
          state.sgr.add token.value
    of atkOsc:
      if token.value.startsWith("\e]8;"):
        let bodyEnd = if token.value.endsWith("\e\\"):
          token.value.len - 2 else: token.value.len - 1
        # OSC 8 is ``ESC ] 8 ; params ; URI terminator``.
        let body = token.value[4 ..< bodyEnd]
        let separator = body.find(';')
        if separator >= 0 and separator + 1 < body.len:
          state.hyperlink = token.value
        else:
          state.hyperlink.setLen(0)
    else:
      discard

proc renderRange(items: seq[StyledUnit]; first, afterLast: int): string =
  if first >= afterLast:
    return ""
  var state: AnsiState
  for index in 0 ..< first:
    state.updateState(items[index].raw)
  let hadPrefix = state.sgr.len > 0
  if hadPrefix:
    result.add state.sgr
  if state.hyperlink.len > 0:
    result.add state.hyperlink
  for index in first ..< afterLast:
    result.add items[index].raw
    state.updateState(items[index].raw)
  if state.hyperlink.len > 0:
    result.add "\e]8;;\e\\"
  if state.sgr.len > 0 or hadPrefix:
    result.add ansiReset

proc displayWidth*(value: string): int =
  ## Returns the width of the widest line in terminal cells. ANSI controls do
  ## not count; combining marks, variation selectors, and joiners do not add a
  ## cell; common East Asian and emoji graphemes occupy two cells.
  let parsed = units(value)
  var lineWidth = 0
  for item in parsed.items:
    if item.newline:
      result = max(result, lineWidth)
      lineWidth = 0
    else:
      lineWidth += item.width
  result = max(result, lineWidth)

proc sliceAnsi*(value: string; startCell, maxWidth: int): string =
  ## Extracts whole graphemes from the first display line while retaining ANSI
  ## style and OSC-8 hyperlink state. A wide grapheme is never split.
  if startCell < 0 or maxWidth < 0:
    raise newException(ValueError, "cell offsets and widths cannot be negative")
  if maxWidth == 0:
    return ""
  let parsed = units(value)
  var position = 0
  var first = -1
  var afterLast = -1
  for index, item in parsed.items:
    if item.newline:
      break
    let itemEnd = position + item.width
    if item.width > 0 and position >= startCell and itemEnd <= startCell + maxWidth:
      if first < 0:
        first = index
      afterLast = index + 1
    position = itemEnd
  if first >= 0:
    result = renderRange(parsed.items, first, afterLast)

proc truncateAnsi*(value: string; maxWidth: int; suffix = "…"): string =
  ## Truncates a single display line and appends ``suffix`` when needed.
  if maxWidth < 0:
    raise newException(ValueError, "maximum width cannot be negative")
  if displayWidth(value) <= maxWidth:
    return value
  let suffixWidth = displayWidth(suffix)
  if suffixWidth >= maxWidth:
    return sliceAnsi(suffix, 0, maxWidth)
  sliceAnsi(value, 0, maxWidth - suffixWidth) & suffix

proc padAnsi*(value: string; width: int; alignment = alignLeft;
              padding = ' '): string =
  ## Pads a single display line to ``width`` terminal cells. Values wider than
  ## ``width`` are returned unchanged.
  if width < 0:
    raise newException(ValueError, "padding width cannot be negative")
  if runeCellWidth(ord(padding)) != 1:
    raise newException(ValueError, "padding must occupy exactly one cell")
  let missing = max(0, width - displayWidth(value))
  var left, right: int
  case alignment
  of alignLeft:
    right = missing
  of alignCenter:
    left = missing div 2
    right = missing - left
  of alignRight:
    left = missing
  repeat(padding, left) & value & repeat(padding, right)

proc wrapAnsi*(value: string; width: int;
               mode = wrapWords): seq[string] =
  ## Wraps styled text to ``width`` cells. Explicit newlines are honored and
  ## active SGR and OSC-8 hyperlink state is restored on each produced line.
  ## Whitespace at a word-wrap boundary is omitted.
  if width <= 0:
    raise newException(ValueError, "wrap width must be positive")
  let parsed = units(value)
  var lineStart = 0
  var lines: seq[string]

  proc wrapLine(first, afterLast: int) =
    if first == afterLast:
      lines.add ""
      return
    let previousLineCount = lines.len
    var start = first
    while start < afterLast:
      while mode == wrapWords and start < afterLast and
          parsed.items[start].whitespace:
        inc start
      if start >= afterLast:
        break
      var index = start
      var used = 0
      var lastSpace = -1
      while index < afterLast:
        let item = parsed.items[index]
        if item.whitespace:
          lastSpace = index
        if used > 0 and used + item.width > width:
          break
        used += item.width
        inc index
        if used >= width:
          break
      if index < afterLast and mode == wrapWords and lastSpace >= start:
        lines.add renderRange(parsed.items, start, lastSpace)
        start = lastSpace + 1
      else:
        lines.add renderRange(parsed.items, start, index)
        start = index
    if lines.len == previousLineCount:
      lines.add ""

  for index, item in parsed.items:
    if item.newline:
      wrapLine(lineStart, index)
      lineStart = index + 1
  wrapLine(lineStart, parsed.items.len)
  result = lines
