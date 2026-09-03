## ============================================================================
## TerminalStyle - Complete Public API & Visual Hero Showcase
## ============================================================================
## Demonstrates EVERY feature of the library in an aesthetic 80x21 card:
##   1. Colors: Standard & Bright ANSI-16 (fg & bg), ANSI-256 indexed, 24-bit RGB & Hex
##   2. Palettes: ansiPalette, defaultDarkPalette, defaultLightPalette, custom brand
##   3. Text Attributes: bold, dim, italic, underline, overline, strike, reverse, blink
##   4. Style Composition: initTerminalStyle, styled, applyStyle, enabled=false mode
##   5. Nested Styles: automatic restoration of outer style after inner reset
##   6. ANSI Parsing: tokenizeAnsi (CSI, OSC, ESC, text), safe malformed input, stripAnsi
##   7. Hyperlinks: OSC-8 clickable terminal hyperlinks
##   8. Unicode Layout: displayWidth, sliceAnsi, truncateAnsi, padAnsi, wrapAnsi
##      (combining marks, East Asian wide, emoji, ZWJ sequences, flags)
## ============================================================================

import std/[strutils]

# Use relative imports if running from inside the repo's examples/ folder:
when isMainModule:
  import ../src/terminal_style
  import ../src/terminal_style/palettes
else:
  import terminal_style
  import terminal_style/palettes

const
  BoxWidth = 80
  InnerWidth = BoxWidth - 4 # Exactly 76 display cells inside borders

# Sleek slate-gray border styling
let borderColor = ansiCode(hexColor("#4a5568"))

proc boxLine(content: string): string =
  ## Pads content to exact cell width and frames it with stylized borders
  let w = displayWidth(content)
  let padLen = max(0, InnerWidth - w)
  borderColor & "│ " & ansiReset & content & repeat(' ', padLen) & borderColor & " │" & ansiReset

proc boxDivider(title: string = ""): string =
  ## Renders a crisp section divider matching box geometry
  if title.len == 0:
    borderColor & "├─" & repeat("─", InnerWidth) & "─┤" & ansiReset
  else:
    let t = " " & title & " "
    let tLen = displayWidth(t)
    let rightDashes = max(0, InnerWidth - tLen)
    borderColor & "├─" & ansiReset & bold(brightWhite(t)) & borderColor & repeat("─", rightDashes) & "─┤" & ansiReset

proc boxTop(title, tag: string): string =
  ## Renders rounded top border with title and tag
  let left = "─ " & title & " "
  let right = " " & tag & " ─"
  let leftW = displayWidth(left)
  let rightW = displayWidth(right)
  let middleDashes = max(0, BoxWidth - 2 - leftW - rightW)
  borderColor & "╭" & left & repeat("─", middleDashes) & right & "╮" & ansiReset

proc boxBottom(badgeText: string): string =
  ## Renders rounded bottom border with footer status pills
  let left = "─ " & badgeText & " "
  let leftW = displayWidth(left)
  let dashes = max(0, BoxWidth - 2 - leftW)
  borderColor & "╰" & left & borderColor & repeat("─", dashes) & "╯" & ansiReset

when isMainModule:
  echo "\n"
  # -------------------------------------------------------------------------
  # HEADER: Title & Badges & OSC-8 Hyperlink
  # -------------------------------------------------------------------------
  echo boxTop(bold(brightCyan("TerminalStyle")), brightBlack("Pure-Nim · Zero-Deps · ANSI/VT"))
  echo boxLine("")
  let b1 = onRgb(22, 40, 75, bold(brightCyan(" Pure-Nim ")))
  let b2 = onRgb(18, 52, 28, bold(brightGreen(" Zero-Deps ")))
  let b3 = onRgb(58, 22, 78, bold(brightMagenta(" TrueColor ")))
  let b4 = onRgb(72, 38, 12, bold(brightYellow(" Cell-Aware ")))
  let ghLink = "\e]8;;https://github.com/titanomachy/terminal-style\e\\" &
    underline(brightWhite("titanomachy/terminal-style")) & "\e]8;;\e\\"
  echo boxLine(b1 & " " & b2 & " " & b3 & " " & b4 & " " & dim("↗ ") & ghLink)
  echo boxLine("")
  
  # -------------------------------------------------------------------------
  # SECTION 1: Color Spaces & Curated Palettes
  # -------------------------------------------------------------------------
  echo boxDivider("1. COLOR SPACES & CURATED PALETTES")

  # Standard & Bright ANSI-16 (Foreground & Background helpers)
  var ansiRow = bold("ANSI-16  ") & dim("Std:") & " "
  ansiRow.add black("■") & red("■") & green("■") & yellow("■") &
    blue("■") & magenta("■") & cyan("■") & white("■")
  ansiRow.add " " & dim("Brt:") & " "
  ansiRow.add brightBlack("■") & brightRed("■") & brightGreen("■") & brightYellow("■") &
    brightBlue("■") & brightMagenta("■") & brightCyan("■") & brightWhite("■")
  ansiRow.add "  " & dim("Bg:") & " "
  ansiRow.add bgRed(brightWhite(" R ")) & bgGreen(brightWhite(" G ")) &
    bgYellow(black(" Y ")) & bgBlue(brightWhite(" B ")) &
    bgMagenta(brightWhite(" M ")) & bgCyan(black(" C ")) &
    bgBrightWhite(black(" W "))
  echo boxLine(ansiRow)

  # ANSI-256 Indexed color ramp & 24-bit RGB/Hex gradient
  var colorRamp = bold("256/RGB  ")
  for idx in [196, 202, 208, 214, 220, 226, 118, 48, 39, 27, 93, 161]:
    colorRamp.add onIndexed(idx, " ")
  colorRamp.add " "
  for idx in [233, 237, 241, 245, 249, 253]:
    colorRamp.add onIndexed(idx, " ")
  colorRamp.add "  " & dim("TrueColor:") & " "
  let hexSteps = ["#ff0055", "#ff5500", "#ffaa00", "#ffee00", "#aaff00", "#00ff66",
                  "#00ffcc", "#00aaff", "#0055ff", "#7700ff", "#cc00ff", "#ff00aa"]
  for hx in hexSteps:
    colorRamp.add background(hexColor(hx), " ")
  colorRamp.add " " & rgb(255, 120, 180, "rgb()") & dim("/") & foreground(hexColor("#78c8ff"), "hexColor()")
  echo boxLine(colorRamp)

  # Reusable Curated Palettes: ANSI-16 vs Dark vs Light vs Custom
  const customBrand = initTerminalPalette(
    red = hexColor("#ff4757"),
    green = hexColor("#2ed573"),
    yellow = hexColor("#ffa502"),
    blue = hexColor("#1e90ff"),
    cyan = hexColor("#00d2d3")
  )
  var palRow = bold("Palettes ")
  palRow.add dim("ANSI:") & " " & foreground(ansiPalette.red, "●") & foreground(ansiPalette.green, "●") &
    foreground(ansiPalette.yellow, "●") & foreground(ansiPalette.blue, "●") & foreground(ansiPalette.cyan, "●")
  palRow.add "  " & dim("Dark:") & " " & foreground(defaultDarkPalette.red, "●") & foreground(defaultDarkPalette.green, "●") &
    foreground(defaultDarkPalette.yellow, "●") & foreground(defaultDarkPalette.blue, "●") & foreground(defaultDarkPalette.cyan, "●")
  palRow.add "  " & dim("Light:") & " " & foreground(defaultLightPalette.red, "●") & foreground(defaultLightPalette.green, "●") &
    foreground(defaultLightPalette.yellow, "●") & foreground(defaultLightPalette.blue, "●") & foreground(defaultLightPalette.cyan, "●")
  palRow.add "  " & dim("Brand:") & " " & foreground(customBrand.red, "●") & foreground(customBrand.green, "●") &
    foreground(customBrand.yellow, "●") & foreground(customBrand.blue, "●") & foreground(customBrand.cyan, "●")
  palRow.add "  " & dim("(curated)")
  echo boxLine(palRow)
  echo boxLine("")

  # -------------------------------------------------------------------------
  # SECTION 2: Text Attributes & Style Composition
  # -------------------------------------------------------------------------
  echo boxDivider("2. TEXT ATTRIBUTES & COMPOSABLE STYLES")

  # All 10 SGR Text Attributes in one glance
  var attrRow = bold("Attribs  ")
  attrRow.add bold("bold") & " " & dim("dim") & " " & italic("italic") & " " &
    underline("underline") & " " & overline("overline") & " " &
    strikethrough("strike") & " " & reverse("reverse") & " " & blink("blink")
  echo boxLine(attrRow)

  # Reusable TerminalStyle object
  let composedStyle = initTerminalStyle(
    foreground = hexColor("#78c8ff"),
    background = indexedColor(236),
    attributes = {taBold, taUnderline}
  )
  echo boxLine(bold("Composed ") & styled(composedStyle, " initTerminalStyle(fg, bg, {taBold, taUnderline}) ") &
    dim(" -> single SGR"))

  # Nested Style Restoration: inner resets do not wipe out outer styling
  let nested = bold("bold [ ", red("red [ ", underline(brightYellow("nested yellow")), " ] red"), " ] restored")
  echo boxLine(bold("Nested   ") & nested & "  " & dim("(outer restored)"))

  # Disabled style / ANSI stripping for clean log files & CI
  let plain = applyStyle(nested, composedStyle, enabled = false)
  echo boxLine(bold("No-ANSI  ") & dim("enabled=false -> ") & brightBlack(plain))
  echo boxLine("")

  # -------------------------------------------------------------------------
  # SECTION 3: Lossless ANSI Parser & OSC-8 Hyperlinks
  # -------------------------------------------------------------------------
  echo boxDivider("3. LOSSLESS ANSI PARSER & OSC-8 HYPERLINKS")

  # Tokenizer losslessly categorizes CSI, OSC, ESC, and Text
  let sample = "\e[32mOK\e[0m \e]8;;https://nim-lang.org\e\\Nim\e]8;;\e\\ \eM\e[31"
  let toks = tokenizeAnsi(sample)
  var tokRow = bold("Tokens   ")
  for t in toks:
    case t.kind
    of atkCsi:
      if t.value == "\e[32m": tokRow.add cyan("[CSI] ")
    of atkOsc:
      if t.value.len > 10: tokRow.add yellow("[OSC-8] ")
    of atkEscape:
      tokRow.add magenta("[ESC] ")
    of atkText:
      if t.value == "OK" or t.value == "Nim":
        tokRow.add brightWhite("\"" & t.value & "\" ")
      elif t.value.startsWith("\e"):
        tokRow.add red("\"\\e[31\"")
  tokRow.add "  " & dim("(lossless tokenizeAnsi)")
  echo boxLine(tokRow)

  # Safe parsing: escape '\e' to visible "\e" so the terminal prints it as text
  let safeDisplay = stripAnsi(sample).replace("\e", "\\e")
  echo boxLine(bold("Safe/Raw ") & "stripAnsi() -> \"" & green(safeDisplay) & "\"   " &
    dim("(unterminated kept verbatim)"))
  echo boxLine("")

  # -------------------------------------------------------------------------
  # SECTION 4: Unicode-Aware Terminal-Cell Layout
  # -------------------------------------------------------------------------
  echo boxDivider("4. UNICODE-AWARE TERMINAL-CELL LAYOUT")

  # Precise cell measurement (combining marks, CJK wide, emoji, flags, ZWJ family)
  let wRow = bold("Widths   ") &
    "\"e\u0301\": " & cyan($displayWidth("e\u0301") & "c") & dim("(3b) ") &
    "\"界\": " & cyan($displayWidth("界") & "c") & dim("(3b) ") &
    "\"💯\": " & cyan($displayWidth("💯") & "c") & dim("(6b) ") &
    "\"🇳🇱\": " & cyan($displayWidth("🇳🇱") & "c") & dim("(8b) ") &
    "\"🚀\": " & cyan($displayWidth("🚀") & "c") & dim("(4b)")
  echo boxLine(wRow)

  # Cell-aware slicing & truncation without splitting graphemes or leaking ANSI
  let sliceSrc = bold(brightMagenta("Nim")) & " " & red("界") & " " & brightGreen("Rocket🚀") & " " & brightCyan("End")
  let sliced = sliceAnsi(sliceSrc, 4, 8)
  let trunc = truncateAnsi(sliceSrc, 9, "…")
  echo boxLine(bold("Slice/Tr ") & "slice(4,8): [" & sliced & "]   truncate(9): [" & trunc & "]")

  # Padding and alignment across terminal cells
  let padL = padAnsi(brightGreen("left"), 20, alignLeft, '.')
  let padC = padAnsi(brightYellow("center"), 20, alignCenter, '.')
  let padR = padAnsi(brightCyan("right"), 20, alignRight, '.')
  echo boxLine(bold("PadAnsi  ") & padL & " " & padC & " " & padR)

  # Word and character wrapping preserving active ANSI colors across lines
  let wrap1 = wrapAnsi(bold(cyan("word wrap ")) & onRgb(35,35,55, brightYellow("preserves ANSI")), 18, wrapWords)
  let wrap2 = wrapAnsi(bold(magenta("char wrap ")) & onRgb(45,25,35, brightGreen("without leak")), 18, wrapCharacters)
  echo boxLine(bold("WrapAnsi ") & "Words: [" & padAnsi(wrap1[0], 18) & "]  " &
    "Chars: [" & padAnsi(wrap2[0], 18) & "]")
  echo boxLine("         " & "       [" & padAnsi(wrap1[1], 18) & "]         [" & padAnsi(wrap2[1], 18) & "]")
  echo boxLine("")

  # Footer border with status pills
  echo boxBottom(brightGreen("● ") & bold("100% Pure Nim") & " · " &
    brightCyan("● ") & bold("Zero Dependencies") & " · " &
    brightMagenta("● ") & bold("Side-Effect Free"))