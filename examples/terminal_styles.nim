## A finite tour of styling and ANSI-aware layout.

when isMainModule:
  import ../src/terminal_styles
  import ../src/terminal_styles/palettes

  echo bold(brightCyan("Terminal styling"))
  echo red("standard red"), "  ", brightRed("bright red"), "  ",
    bgBlue(white(" white on blue "))

  var indexedSwatches = "ANSI-256: "
  for index in countup(16, 231, 18):
    indexedSwatches.add onIndexed(index, "  ")
  echo indexedSwatches

  echo "\nReusable palettes"
  echo foreground(ansiPalette.red, "ANSI red"), "  ",
    foreground(defaultDarkPalette.red, "dark-palette red"), "  ",
    foreground(defaultLightPalette.red, "light-palette red")
  const companyPalette = initTerminalPalette(
    red = hexColor("#dc4650"),
    blue = hexColor("#4682dc")
  )
  echo foreground(companyPalette.blue, "custom blue")

  let heading = initTerminalStyle(
    foreground = hexColor("#78c8ff"),
    background = indexedColor(17),
    attributes = {taBold, taUnderline}
  )
  echo styled(heading, " reusable composed style ")
  echo rgb(120, 200, 255, "24-bit foreground"), "  ",
    onRgb(35, 42, 58, brightYellow(" true-color panel "))

  let nested = bold("outer bold, ", magenta("nested magenta"),
    ", bold restored")
  echo nested
  echo "plain/log output: ", applyStyle(nested, heading, enabled = false)

  echo "\nCell-aware layout"
  let sample = red("Nim 界 👨‍👩‍👧‍👦 e\u0301")
  echo "width: ", displayWidth(sample)
  echo "slice: |", padAnsi(sliceAnsi(sample, 4, 4), 10, alignCenter), "|"
  for line in wrapAnsi(bold("styled text wraps without leaking its style"), 16):
    echo "|", padAnsi(line, 16), "|"
