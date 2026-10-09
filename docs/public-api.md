# Public API example map

Every exported symbol has an API doc comment in its defining module. The
finite `examples/terminal_style.nim` program is compiled by `nimble examples`
and demonstrates color constructors, foreground/background helpers, text
attributes, reusable styles, built-in and custom palettes, ANSI stripping and
tokenization, terminal-cell measurement, slicing, truncation, padding, and
wrapping. Its nested-color example includes an RGB color with zero components,
and its width examples include Thai and Lao text.

Exact escape sequences, Unicode grapheme behavior, OSC hyperlinks, nested
style restoration, and invalid dimensions are covered by
`tests/test_terminal_style.nim`. Regression cases also cover zero RGB components
and palette index `0` in foreground and background colors, style parameters
following a reset in the same SGR sequence, and closing colors during slicing,
truncation, and wrapping.

The layout tests check Thai and Lao spacing characters separately from their
combining marks, including slicing, padding, truncation, and character wrapping.
Wrapping tests preserve styles and OSC-8 links across discarded whitespace and
newlines. A large multiline input checks output correctness and uses a generous
CPU-time limit to catch repeated prefix scans.

The opt-in `terminal_style/palettes` module documents `TerminalPalette`,
`initTerminalPalette`, `ansiPalette`, `defaultDarkPalette`, and
`defaultLightPalette`. Exact values, ANSI defaults, focused-module exports,
style composition, and value semantics are covered by
`tests/test_palettes.nim`. The dedicated [`color-palettes.md`](color-palettes.md)
guide contains the viewable color table and customization guidance.
