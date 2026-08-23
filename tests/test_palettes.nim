import std/unittest

import terminal_styles/palettes

suite "terminal color palettes":
  test "maps the ANSI palette to existing terminal colors":
    check [
      ansiPalette.black, ansiPalette.red, ansiPalette.green,
      ansiPalette.yellow, ansiPalette.blue, ansiPalette.magenta,
      ansiPalette.cyan, ansiPalette.white, ansiPalette.brightBlack,
      ansiPalette.brightRed, ansiPalette.brightGreen,
      ansiPalette.brightYellow, ansiPalette.brightBlue,
      ansiPalette.brightMagenta, ansiPalette.brightCyan,
      ansiPalette.brightWhite
    ] == [
      colorBlack, colorRed, colorGreen, colorYellow, colorBlue, colorMagenta,
      colorCyan, colorWhite, colorBrightBlack, colorBrightRed,
      colorBrightGreen, colorBrightYellow, colorBrightBlue,
      colorBrightMagenta, colorBrightCyan, colorBrightWhite
    ]

  test "stores the approved dark RGB values exactly":
    check [
      defaultDarkPalette.black, defaultDarkPalette.red,
      defaultDarkPalette.green, defaultDarkPalette.yellow,
      defaultDarkPalette.blue, defaultDarkPalette.magenta,
      defaultDarkPalette.cyan, defaultDarkPalette.white,
      defaultDarkPalette.brightBlack, defaultDarkPalette.brightRed,
      defaultDarkPalette.brightGreen, defaultDarkPalette.brightYellow,
      defaultDarkPalette.brightBlue, defaultDarkPalette.brightMagenta,
      defaultDarkPalette.brightCyan, defaultDarkPalette.brightWhite
    ] == [
      rgbColor(16, 20, 24), rgbColor(239, 102, 97),
      rgbColor(70, 178, 80), rgbColor(185, 147, 5),
      rgbColor(86, 150, 255), rgbColor(203, 111, 209),
      rgbColor(1, 172, 186), rgbColor(213, 221, 229),
      rgbColor(116, 129, 142), rgbColor(255, 171, 163),
      rgbColor(129, 221, 133), rgbColor(234, 191, 58),
      rgbColor(162, 197, 255), rgbColor(245, 161, 249),
      rgbColor(0, 221, 239), rgbColor(245, 247, 250)
    ]

  test "stores the approved light RGB values exactly":
    check [
      defaultLightPalette.black, defaultLightPalette.red,
      defaultLightPalette.green, defaultLightPalette.yellow,
      defaultLightPalette.blue, defaultLightPalette.magenta,
      defaultLightPalette.cyan, defaultLightPalette.white,
      defaultLightPalette.brightBlack, defaultLightPalette.brightRed,
      defaultLightPalette.brightGreen, defaultLightPalette.brightYellow,
      defaultLightPalette.brightBlue, defaultLightPalette.brightMagenta,
      defaultLightPalette.brightCyan, defaultLightPalette.brightWhite
    ] == [
      rgbColor(24, 32, 40), rgbColor(124, 17, 23),
      rgbColor(1, 82, 17), rgbColor(82, 64, 1),
      rgbColor(11, 61, 139), rgbColor(101, 30, 106),
      rgbColor(2, 76, 82), rgbColor(227, 232, 237),
      rgbColor(77, 89, 102), rgbColor(172, 48, 49),
      rgbColor(1, 121, 30), rgbColor(122, 96, 1),
      rgbColor(37, 94, 188), rgbColor(142, 59, 148),
      rgbColor(2, 113, 122), rgbColor(247, 248, 250)
    ]

  test "defaults omitted custom slots to ANSI colors":
    let custom = initTerminalPalette(
      red = rgbColor(220, 70, 80),
      blue = indexedColor(33)
    )
    check custom.red == rgbColor(220, 70, 80)
    check custom.blue == indexedColor(33)
    check custom.green == colorGreen
    check custom.brightWhite == colorBrightWhite

  test "works with the focused module's re-exported styling API":
    check foreground(defaultDarkPalette.red, "failed") ==
      "\e[38;2;239;102;97mfailed\e[0m"
    check background(defaultLightPalette.white, "surface") ==
      "\e[48;2;227;232;237msurface\e[0m"

    let heading = initTerminalStyle(
      foreground = defaultDarkPalette.blue,
      attributes = {taBold}
    )
    check styled(heading, "heading") ==
      "\e[1;38;2;86;150;255mheading\e[0m"

  test "preserves value semantics in sequences and closures":
    let palettes = @[defaultDarkPalette, defaultLightPalette]
    let captured = palettes[0]
    let pickBlue = proc(): TerminalColor = captured.blue
    check palettes[1].red == rgbColor(124, 17, 23)
    check pickBlue() == rgbColor(86, 150, 255)
