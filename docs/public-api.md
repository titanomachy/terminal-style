# Public API example map

Every exported symbol has an API doc comment in its defining module. The
finite `examples/terminal_styles.nim` program is compiled by `nimble examples`
and demonstrates color constructors, foreground/background helpers, text
attributes, reusable styles, built-in and custom palettes, ANSI stripping and
tokenization, terminal-cell measurement, slicing, truncation, padding, and
wrapping.

Exact escape sequences, Unicode grapheme behavior, OSC hyperlinks, nested
style restoration, and invalid dimensions are covered by
`tests/test_terminal_styles.nim`.

The opt-in `terminal_styles/palettes` module documents `TerminalPalette`,
`initTerminalPalette`, `ansiPalette`, `defaultDarkPalette`, and
`defaultLightPalette`. Exact values, ANSI defaults, focused-module exports,
style composition, and value semantics are covered by
`tests/test_palettes.nim`. The dedicated [`color-palettes.md`](color-palettes.md)
guide contains the viewable color table and customization guidance.
