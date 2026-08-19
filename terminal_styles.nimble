# Package

version       = "0.1.0"
author        = "titanomachy"
description   = "ANSI styling and terminal-aware text utilities for Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task test, "Run the terminal_styles test suite":
  exec "nim r --path:src tests/test_terminal_styles.nim"

task examples, "Check that all examples compile":
  exec "nim check examples/terminal_styles.nim"

task docs, "Generate terminal_styles API documentation":
  exec "nim doc --outdir:htmldocs --path:src src/terminal_styles.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_styles/ansi.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_styles/colors.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_styles/widths.nim"
