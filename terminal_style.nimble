# Package

version       = "0.1.0"
author        = "titanomachy"
description   = "ANSI styling and terminal-aware text utilities for Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"

task test, "Run the terminal_style test suite":
  exec "nim r --path:src tests/test_terminal_style.nim"
  exec "nim r --path:src tests/test_palettes.nim"

task examples, "Check that all examples compile":
  exec "nim check examples/terminal_style.nim"

task docs, "Generate terminal_style API documentation":
  exec "nim doc --outdir:htmldocs --path:src src/terminal_style.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_style/ansi.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_style/colors.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_style/palettes.nim"
  exec "nim doc --outdir:htmldocs --path:src src/terminal_style/widths.nim"
