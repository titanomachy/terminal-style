# Public API example map

Every exported symbol has an API doc comment in its defining module. The
finite `examples/terminal_styles.nim` program is compiled by `nimble examples`
and demonstrates color constructors, foreground/background helpers, text
attributes, reusable styles, ANSI stripping and tokenization, terminal-cell
measurement, slicing, truncation, padding, and wrapping.

Exact escape sequences, Unicode grapheme behavior, OSC hyperlinks, nested
style restoration, and invalid dimensions are covered by
`tests/test_terminal_styles.nim`.

