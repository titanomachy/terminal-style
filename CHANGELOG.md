# Changelog

This project follows Semantic Versioning.

## [Unreleased]

## [0.1.1] - 2026-08-24

### Changed

- Rename the repository and Nimble package to the singular
  `terminal-style`/`terminal_style` names to avoid a Nimble namespace conflict.

## [0.1.0] - 2026-08-23

### Added

- Add a dependency-free, pure-Nim façade for terminal styling, ANSI parsing,
  and terminal-cell-aware text layout.
- Add standard and bright 16-color, ANSI-256 indexed, 24-bit RGB, and
  three- or six-digit hexadecimal terminal colors.
- Add an opt-in palette module with ANSI defaults, original dark and light RGB
  presets, partial custom-palette construction, and a viewable color guide.
- Add foreground and background helpers, text attributes, and reusable
  composable `TerminalStyle` values.
- Restore outer formatting after nested content resets its ANSI style, with an
  option to disable styling and return plain text for logs or redirected
  output.
- Add lossless tokenization for complete CSI, OSC, and two-byte escape
  sequences, including OSC-8 hyperlinks terminated by BEL or ST.
- Add ANSI stripping that preserves malformed or incomplete escape sequences
  as ordinary text instead of discarding content.
- Add Unicode terminal-cell measurement for combining marks, East Asian wide
  characters, emoji variation sequences, flags, and joined emoji graphemes.
- Add cell-aware slicing, truncation, left/center/right padding, word wrapping,
  and character wrapping without splitting wide or joined graphemes.
- Preserve and correctly close active SGR styles and OSC-8 hyperlinks across
  sliced, truncated, and wrapped output.

### Compatibility

- Support Nim 2.0.0 and newer.
