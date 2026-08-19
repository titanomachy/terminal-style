## Terminal colors, text attributes, and composable styles.
##
## All helpers return strings and have no terminal or global-state side effects.

import std/strutils

import ./ansi

export ansi

type
  TerminalColorKind* = enum
    ## Encoding used by a ``TerminalColor``.
    tckDefault,
    tckAnsi16,
    tckAnsi256,
    tckRgb

  TerminalColor* = object
    ## A foreground or background color supported by modern terminals.
    ##
    ## Components not used by ``kind`` remain zero. A regular object is used
    ## instead of a case object so color values remain safe in sequences and
    ## closure captures across all supported Nim 2.x compilers.
    kind*: TerminalColorKind
    index*: uint8
    red*, green*, blue*: uint8

  ColorPlane* = enum
    ## Selects whether a color affects text or its background.
    cpForeground,
    cpBackground

  TextAttribute* = enum
    ## Independently composable SGR text attributes.
    taBold,
    taDim,
    taItalic,
    taUnderline,
    taBlink,
    taRapidBlink,
    taReverse,
    taConceal,
    taStrikethrough,
    taOverline

  TerminalStyle* = object
    ## A reusable foreground, background, and attribute combination.
    foreground*: TerminalColor
    background*: TerminalColor
    attributes*: set[TextAttribute]

proc `==`*(left, right: TerminalColor): bool =
  ## Compares colors by encoding and component values.
  if left.kind != right.kind:
    return false
  case left.kind
  of tckDefault:
    true
  of tckAnsi16, tckAnsi256:
    left.index == right.index
  of tckRgb:
    left.red == right.red and left.green == right.green and
      left.blue == right.blue

const
  colorDefault* = TerminalColor(kind: tckDefault)
  colorBlack* = TerminalColor(kind: tckAnsi16, index: 0)
  colorRed* = TerminalColor(kind: tckAnsi16, index: 1)
  colorGreen* = TerminalColor(kind: tckAnsi16, index: 2)
  colorYellow* = TerminalColor(kind: tckAnsi16, index: 3)
  colorBlue* = TerminalColor(kind: tckAnsi16, index: 4)
  colorMagenta* = TerminalColor(kind: tckAnsi16, index: 5)
  colorCyan* = TerminalColor(kind: tckAnsi16, index: 6)
  colorWhite* = TerminalColor(kind: tckAnsi16, index: 7)
  colorBrightBlack* = TerminalColor(kind: tckAnsi16, index: 8)
  colorBrightRed* = TerminalColor(kind: tckAnsi16, index: 9)
  colorBrightGreen* = TerminalColor(kind: tckAnsi16, index: 10)
  colorBrightYellow* = TerminalColor(kind: tckAnsi16, index: 11)
  colorBrightBlue* = TerminalColor(kind: tckAnsi16, index: 12)
  colorBrightMagenta* = TerminalColor(kind: tckAnsi16, index: 13)
  colorBrightCyan* = TerminalColor(kind: tckAnsi16, index: 14)
  colorBrightWhite* = TerminalColor(kind: tckAnsi16, index: 15)

  termClear* = ansiReset
  termBlack* = "\e[30m"
  termRed* = "\e[31m"
  termGreen* = "\e[32m"
  termYellow* = "\e[33m"
  termBlue* = "\e[34m"
  termMagenta* = "\e[35m"
  termCyan* = "\e[36m"
  termWhite* = "\e[37m"
  termBrightBlack* = "\e[90m"
  termBrightRed* = "\e[91m"
  termBrightGreen* = "\e[92m"
  termBrightYellow* = "\e[93m"
  termBrightBlue* = "\e[94m"
  termBrightMagenta* = "\e[95m"
  termBrightCyan* = "\e[96m"
  termBrightWhite* = "\e[97m"
  termBgBlack* = "\e[40m"
  termBgRed* = "\e[41m"
  termBgGreen* = "\e[42m"
  termBgYellow* = "\e[43m"
  termBgBlue* = "\e[44m"
  termBgMagenta* = "\e[45m"
  termBgCyan* = "\e[46m"
  termBgWhite* = "\e[47m"
  termBgBrightBlack* = "\e[100m"
  termBgBrightRed* = "\e[101m"
  termBgBrightGreen* = "\e[102m"
  termBgBrightYellow* = "\e[103m"
  termBgBrightBlue* = "\e[104m"
  termBgBrightMagenta* = "\e[105m"
  termBgBrightCyan* = "\e[106m"
  termBgBrightWhite* = "\e[107m"
  termBold* = "\e[1m"
  termDim* = "\e[2m"
  termItalic* = "\e[3m"
  termUnderline* = "\e[4m"
  termBlink* = "\e[5m"
  termRapidBlink* = "\e[6m"
  termNegative* = "\e[7m"
  termReverse* = termNegative
  termConceal* = "\e[8m"
  termHidden* = termConceal
  termStrikethrough* = "\e[9m"
  termOverline* = "\e[53m"

proc ansi16Color*(index: range[0 .. 15]): TerminalColor =
  ## Constructs one of the 16 standard terminal colors.
  TerminalColor(kind: tckAnsi16, index: uint8(index))

proc indexedColor*(index: range[0 .. 255]): TerminalColor =
  ## Constructs an ANSI-256 palette color.
  TerminalColor(kind: tckAnsi256, index: uint8(index))

proc rgbColor*(red, green, blue: range[0 .. 255]): TerminalColor =
  ## Constructs a 24-bit true-color value.
  TerminalColor(kind: tckRgb, red: uint8(red), green: uint8(green),
    blue: uint8(blue))

proc hexColor*(value: string): TerminalColor =
  ## Parses ``#RGB``, ``RGB``, ``#RRGGBB``, or ``RRGGBB`` as true color.
  let digits = if value.startsWith('#'): value[1 .. ^1] else: value
  if digits.len notin {3, 6}:
    raise newException(ValueError, "a hex color must contain 3 or 6 digits")
  for digit in digits:
    if digit notin HexDigits:
      raise newException(ValueError, "invalid hexadecimal color: " & value)
  if digits.len == 3:
    return rgbColor(parseHexInt($digits[0] & $digits[0]),
      parseHexInt($digits[1] & $digits[1]),
      parseHexInt($digits[2] & $digits[2]))
  rgbColor(parseHexInt(digits[0 .. 1]), parseHexInt(digits[2 .. 3]),
    parseHexInt(digits[4 .. 5]))

proc ansiCode*(color: TerminalColor; plane = cpForeground): string =
  ## Returns an SGR escape sequence for ``color`` and ``plane``.
  let foreground = plane == cpForeground
  case color.kind
  of tckDefault:
    "\e[" & $(if foreground: 39 else: 49) & "m"
  of tckAnsi16:
    let index = int(color.index)
    if index < 8:
      "\e[" & $((if foreground: 30 else: 40) + index) & "m"
    else:
      "\e[" & $((if foreground: 90 else: 100) + index - 8) & "m"
  of tckAnsi256:
    "\e[" & $(if foreground: 38 else: 48) & ";5;" & $color.index & "m"
  of tckRgb:
    "\e[" & $(if foreground: 38 else: 48) & ";2;" & $color.red & ";" &
      $color.green & ";" & $color.blue & "m"

proc attributeParameter(attribute: TextAttribute): int =
  case attribute
  of taBold: 1
  of taDim: 2
  of taItalic: 3
  of taUnderline: 4
  of taBlink: 5
  of taRapidBlink: 6
  of taReverse: 7
  of taConceal: 8
  of taStrikethrough: 9
  of taOverline: 53

proc ansiCode*(attribute: TextAttribute): string =
  ## Returns the SGR escape sequence for one text attribute.
  "\e[" & $attributeParameter(attribute) & "m"

proc initTerminalStyle*(foreground = colorDefault;
                        background = colorDefault;
                        attributes: set[TextAttribute] = {}): TerminalStyle =
  ## Creates a reusable style. Default colors are left unchanged.
  TerminalStyle(foreground: foreground, background: background,
    attributes: attributes)

proc ansiCode*(textStyle: TerminalStyle): string =
  ## Returns one combined SGR sequence for all configured style properties.
  var parameters: seq[string]
  for attribute in TextAttribute:
    if attribute in textStyle.attributes:
      parameters.add $attributeParameter(attribute)

  proc addColor(color: TerminalColor; plane: ColorPlane) =
    case color.kind
    of tckDefault:
      discard
    of tckAnsi16:
      let index = int(color.index)
      if index < 8:
        parameters.add $((if plane == cpForeground: 30 else: 40) + index)
      else:
        parameters.add $((if plane == cpForeground: 90 else: 100) + index - 8)
    of tckAnsi256:
      parameters.add $(if plane == cpForeground: 38 else: 48)
      parameters.add "5"
      parameters.add $color.index
    of tckRgb:
      parameters.add $(if plane == cpForeground: 38 else: 48)
      parameters.add "2"
      parameters.add $color.red
      parameters.add $color.green
      parameters.add $color.blue

  addColor(textStyle.foreground, cpForeground)
  addColor(textStyle.background, cpBackground)
  if parameters.len == 0: "" else: "\e[" & parameters.join(";") & "m"

proc applyStyle*(value: string; textStyle: TerminalStyle;
                 enabled = true): string =
  ## Applies ``textStyle``. Disabling it also removes existing ANSI controls.
  composeAnsi(ansiCode(textStyle), value, enabled)

proc styled*(textStyle: TerminalStyle;
             values: varargs[string, `$`]): string =
  ## Concatenates heterogeneous ``values`` and applies ``textStyle``.
  applyStyle(values.join(), textStyle)

proc foreground*(color: TerminalColor;
                 values: varargs[string, `$`]): string =
  ## Applies an arbitrary foreground color.
  composeAnsi(ansiCode(color), values.join())

proc background*(color: TerminalColor;
                 values: varargs[string, `$`]): string =
  ## Applies an arbitrary background color.
  composeAnsi(ansiCode(color, cpBackground), values.join())

proc rgb*(red, green, blue: range[0 .. 255];
          values: varargs[string, `$`]): string =
  ## Applies a 24-bit RGB foreground color.
  foreground(rgbColor(red, green, blue), values.join())

proc onRgb*(red, green, blue: range[0 .. 255];
            values: varargs[string, `$`]): string =
  ## Applies a 24-bit RGB background color.
  background(rgbColor(red, green, blue), values.join())

proc indexed*(index: range[0 .. 255];
              values: varargs[string, `$`]): string =
  ## Applies an ANSI-256 foreground color.
  foreground(indexedColor(index), values.join())

proc onIndexed*(index: range[0 .. 255];
                values: varargs[string, `$`]): string =
  ## Applies an ANSI-256 background color.
  background(indexedColor(index), values.join())

template defineStyleHelper(name, opening: untyped) =
  proc name*(values: varargs[string, `$`]): string =
    composeAnsi(opening, values.join())

defineStyleHelper(black, termBlack)
defineStyleHelper(red, termRed)
defineStyleHelper(green, termGreen)
defineStyleHelper(yellow, termYellow)
defineStyleHelper(blue, termBlue)
defineStyleHelper(magenta, termMagenta)
defineStyleHelper(cyan, termCyan)
defineStyleHelper(white, termWhite)
defineStyleHelper(brightBlack, termBrightBlack)
defineStyleHelper(brightRed, termBrightRed)
defineStyleHelper(brightGreen, termBrightGreen)
defineStyleHelper(brightYellow, termBrightYellow)
defineStyleHelper(brightBlue, termBrightBlue)
defineStyleHelper(brightMagenta, termBrightMagenta)
defineStyleHelper(brightCyan, termBrightCyan)
defineStyleHelper(brightWhite, termBrightWhite)
defineStyleHelper(bgBlack, termBgBlack)
defineStyleHelper(bgRed, termBgRed)
defineStyleHelper(bgGreen, termBgGreen)
defineStyleHelper(bgYellow, termBgYellow)
defineStyleHelper(bgBlue, termBgBlue)
defineStyleHelper(bgMagenta, termBgMagenta)
defineStyleHelper(bgCyan, termBgCyan)
defineStyleHelper(bgWhite, termBgWhite)
defineStyleHelper(bgBrightBlack, termBgBrightBlack)
defineStyleHelper(bgBrightRed, termBgBrightRed)
defineStyleHelper(bgBrightGreen, termBgBrightGreen)
defineStyleHelper(bgBrightYellow, termBgBrightYellow)
defineStyleHelper(bgBrightBlue, termBgBrightBlue)
defineStyleHelper(bgBrightMagenta, termBgBrightMagenta)
defineStyleHelper(bgBrightCyan, termBgBrightCyan)
defineStyleHelper(bgBrightWhite, termBgBrightWhite)
defineStyleHelper(bold, termBold)
defineStyleHelper(dim, termDim)
defineStyleHelper(italic, termItalic)
defineStyleHelper(underline, termUnderline)
defineStyleHelper(blink, termBlink)
defineStyleHelper(rapidBlink, termRapidBlink)
defineStyleHelper(negative, termNegative)
defineStyleHelper(reverse, termReverse)
defineStyleHelper(conceal, termConceal)
defineStyleHelper(hidden, termHidden)
defineStyleHelper(strikethrough, termStrikethrough)
defineStyleHelper(overline, termOverline)

proc style*(values: varargs[string, `$`]; style: string): string =
  ## Applies a raw SGR sequence. Prefer ``TerminalStyle`` for new code.
  composeAnsi(style, values.join())

proc style*(value: string; textStyle: TerminalStyle;
            enabled = true): string =
  ## Concise alias for ``applyStyle``.
  applyStyle(value, textStyle, enabled)
