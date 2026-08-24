## Immutable, reusable sets of standard and bright terminal colors.
##
## Palettes are explicit values. Importing this module does not select a
## palette or change the existing color helpers. The curated RGB palettes are
## designed for true-color terminals and document the background against
## which their foreground colors were chosen.
##
## .. code-block:: nim
##
##   import terminal_style/palettes
##
##   let colors = defaultDarkPalette
##   echo foreground(colors.red, "failed")
##   echo styled(initTerminalStyle(foreground = colors.blue), "information")

import ./colors

export colors

type
  TerminalPalette* = object
    ## A coherent set of colors matching the standard and bright ANSI-16
    ## vocabulary. Fields may contain standard, indexed, or RGB colors.
    black*, red*, green*, yellow*: TerminalColor
    blue*, magenta*, cyan*, white*: TerminalColor
    brightBlack*, brightRed*, brightGreen*, brightYellow*: TerminalColor
    brightBlue*, brightMagenta*, brightCyan*, brightWhite*: TerminalColor

proc initTerminalPalette*(
    black: TerminalColor = colorBlack;
    red: TerminalColor = colorRed;
    green: TerminalColor = colorGreen;
    yellow: TerminalColor = colorYellow;
    blue: TerminalColor = colorBlue;
    magenta: TerminalColor = colorMagenta;
    cyan: TerminalColor = colorCyan;
    white: TerminalColor = colorWhite;
    brightBlack: TerminalColor = colorBrightBlack;
    brightRed: TerminalColor = colorBrightRed;
    brightGreen: TerminalColor = colorBrightGreen;
    brightYellow: TerminalColor = colorBrightYellow;
    brightBlue: TerminalColor = colorBrightBlue;
    brightMagenta: TerminalColor = colorBrightMagenta;
    brightCyan: TerminalColor = colorBrightCyan;
    brightWhite: TerminalColor = colorBrightWhite
): TerminalPalette =
  ## Creates a palette, defaulting each omitted slot to its corresponding
  ## terminal-controlled ANSI-16 color.
  TerminalPalette(
    black: black,
    red: red,
    green: green,
    yellow: yellow,
    blue: blue,
    magenta: magenta,
    cyan: cyan,
    white: white,
    brightBlack: brightBlack,
    brightRed: brightRed,
    brightGreen: brightGreen,
    brightYellow: brightYellow,
    brightBlue: brightBlue,
    brightMagenta: brightMagenta,
    brightCyan: brightCyan,
    brightWhite: brightWhite
  )

const
  ansiPalette* = initTerminalPalette()
    ## Compatibility palette backed by the terminal-controlled ANSI-16
    ## colors.

  defaultDarkPalette* = initTerminalPalette(
    black = rgbColor(16, 20, 24),
    red = rgbColor(239, 102, 97),
    green = rgbColor(70, 178, 80),
    yellow = rgbColor(185, 147, 5),
    blue = rgbColor(86, 150, 255),
    magenta = rgbColor(203, 111, 209),
    cyan = rgbColor(1, 172, 186),
    white = rgbColor(213, 221, 229),
    brightBlack = rgbColor(116, 129, 142),
    brightRed = rgbColor(255, 171, 163),
    brightGreen = rgbColor(129, 221, 133),
    brightYellow = rgbColor(234, 191, 58),
    brightBlue = rgbColor(162, 197, 255),
    brightMagenta = rgbColor(245, 161, 249),
    brightCyan = rgbColor(0, 221, 239),
    brightWhite = rgbColor(245, 247, 250)
  )
    ## Exact RGB colors designed against a ``#101418`` dark background.
    ## ``black`` is the reference background rather than a readable
    ## foreground color.

  defaultLightPalette* = initTerminalPalette(
    black = rgbColor(24, 32, 40),
    red = rgbColor(124, 17, 23),
    green = rgbColor(1, 82, 17),
    yellow = rgbColor(82, 64, 1),
    blue = rgbColor(11, 61, 139),
    magenta = rgbColor(101, 30, 106),
    cyan = rgbColor(2, 76, 82),
    white = rgbColor(227, 232, 237),
    brightBlack = rgbColor(77, 89, 102),
    brightRed = rgbColor(172, 48, 49),
    brightGreen = rgbColor(1, 121, 30),
    brightYellow = rgbColor(122, 96, 1),
    brightBlue = rgbColor(37, 94, 188),
    brightMagenta = rgbColor(142, 59, 148),
    brightCyan = rgbColor(2, 113, 122),
    brightWhite = rgbColor(247, 248, 250)
  )
    ## Exact RGB colors designed against a ``#F7F8FA`` light background.
    ## ``white`` and ``brightWhite`` are surface colors rather than readable
    ## foreground colors.
