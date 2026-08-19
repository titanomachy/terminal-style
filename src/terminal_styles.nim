## Pure-Nim terminal colors, ANSI parsing, and cell-aware text layout.
##
## Importing this façade has no side effects. Styling helpers only construct
## strings; callers decide where and whether to print them.
##
## .. code-block:: nim
##
##   import terminal_styles
##
##   let heading = initTerminalStyle(
##     foreground = rgbColor(120, 200, 255),
##     attributes = {taBold, taUnderline}
##   )
##   echo styled(heading, "Terminal output")
##   echo padAnsi(red("ready"), 12, alignCenter)

import terminal_styles/[ansi, colors, widths]

export ansi, colors, widths
