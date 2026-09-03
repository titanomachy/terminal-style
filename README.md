# TerminalStyle

[![Coverage](https://titanomachy.github.io/terminal-style/coverage.svg)](https://github.com/titanomachy/terminal-style/actions/workflows/pages.yml)

TerminalStyle is a dependency-free, pure-Nim library for terminal colors,
text attributes, ANSI parsing, and Unicode terminal-cell layout. Importing it does not print, query the terminal, or modify global state.

`terminal_style` is the shared styling foundation for `terminal_graphs` and
`terminal_tables`, but can also be used independently.

![TerminalStyle showcase](docs/assets/full-showcase.png)

## Platform support

`terminal_style` has been tested on **Linux** and **Windows**. On Windows I tested with the Terminal app which comes with Windows, other terminals may or may not work. It should also work on **macOS** through its standard POSIX terminal and ANSI/VT support, but macOS has not yet been tested directly.

## Requirements

- Nim 2.0.0 or newer

## Table of contents

- [TerminalStyle](#terminalstyle)
  - [Platform support](#platform-support)
  - [Requirements](#requirements)
  - [Table of contents](#table-of-contents)
  - [Installation](#installation)
  - [Quick start](#quick-start)
  - [API overview](#api-overview)
    - [Colors and attributes](#colors-and-attributes)
    - [Curated RGB palettes](#curated-rgb-palettes)
    - [ANSI parsing](#ansi-parsing)
    - [Terminal-cell layout](#terminal-cell-layout)
  - [Modules](#modules)
  - [Examples](#examples)
  - [Development and documentation](#development-and-documentation)
  - [Attribution and license](#attribution-and-license)

## Installation
Install the current version with Nimble:

```shell
nimble install terminal_style
```

Or if you prefer directly via Github:

```shell
nimble install https://github.com/titanomachy/terminal-style
```

Then import the complete core API:

```nim
import terminal_style
```

## Quick start

A very simple example that styles text:

```nim
import terminal_style

echo red("standard red")
echo bgBlue(white(" white on blue "))
echo brightGreen(bold("bright green in bold"))
```

## API overview

| API family | Main API | Highlights |
| --- | --- | --- |
| [Colors and attributes](#colors-and-attributes) | `TerminalColor`, `TerminalStyle`, `initTerminalStyle`, `styled`, `foreground`, `background`, color and attribute helpers | Standard and bright ANSI colors, ANSI-256, RGB, hex colors, composable text attributes, nested-style restoration, and optional ANSI-free output |
| [Curated RGB palettes](#curated-rgb-palettes) | `TerminalPalette`, `initTerminalPalette`, `ansiPalette`, `defaultDarkPalette`, `defaultLightPalette` | Immutable ANSI-16-compatible palettes, exact dark- and light-background RGB presets, and custom palette construction |
| [ANSI parsing](#ansi-parsing) | `AnsiToken`, `AnsiTokenKind`, `tokenizeAnsi`, `stripAnsi`, `composeAnsi` | Lossless CSI, OSC, and escape tokenization; safe malformed-input handling; OSC-8 hyperlinks; stripping; and nested SGR composition |
| [Terminal-cell layout](#terminal-cell-layout) | `displayWidth`, `sliceAnsi`, `truncateAnsi`, `padAnsi`, `wrapAnsi` | ANSI-aware measurement and layout, Unicode grapheme safety, wide characters, emoji, alignment, word or character wrapping, and retained styles and hyperlinks |

Most applications should import `terminal_style`. Import
`terminal_style/palettes` when using the opt-in palette types and presets. All
rendering is string-based and side-effect free.

### Colors and attributes

Import the façade to access the complete core API:

```nim
import terminal_style

echo red("failed after ", 3, " attempts")
echo bgBrightBlue(brightWhite(" healthy "))
echo rgb(120, 200, 255, "true color")
echo onIndexed(235, brightYellow(" warning "))
```

![Colors, attributes, indexed colors, and true-color output](docs/assets/colors-and-attributes.png)

`TerminalColor` supports the standard and bright 16-color palette, all 256
indexed colors, 24-bit RGB values, and three- or six-digit hexadecimal values:

```nim
let heading = initTerminalStyle(
  foreground = hexColor("#78c8ff"),
  background = indexedColor(17),
  attributes = {taBold, taUnderline}
)

echo styled(heading, "Terminal output")
```

Nested helpers restore the outer style after an inner reset. To produce plain
logs or redirected output, pass `enabled = false`; existing complete ANSI
controls are removed too:

```nim
let decorated = bold("outer ", red("inner"), " outer")
echo applyStyle(decorated, heading, enabled = false)
```

### Curated RGB palettes

Import the opt-in palettes module when you want a coherent set of exact color
choices instead of selecting individual RGB shades:

```nim
import terminal_style/palettes

let colors = defaultDarkPalette

echo foreground(colors.red, "failed")
echo foreground(colors.blue, "information")
echo styled(initTerminalStyle(foreground = colors.cyan), "heading")
```

`ansiPalette` uses terminal-controlled ANSI-16 colors. The original
`defaultDarkPalette` and `defaultLightPalette` presets provide exact RGB
values designed against `#101418` and `#F7F8FA` respectively. Palettes are
ordinary immutable values: importing the module does not select one globally
or change helpers such as `red()`.

![The sixteen dark and light palette colors with hexadecimal values and reference contrast ratios](docs/assets/color-palettes.svg)

See the [color palette guide](docs/color-palettes.md) for exact values,
contrast context, custom palettes, and guidance on choosing a preset.

### ANSI parsing

`tokenizeAnsi` losslessly separates plain text, CSI controls, OSC controls, and
two-byte escape sequences. Only complete sequences are treated as controls.
Malformed or unterminated input remains ordinary text, so content is never
silently discarded.

```nim
let link = "\e]8;;https://example.com\e\\docs\e]8;;\e\\"
doAssert stripAnsi(link) == "docs"

for token in tokenizeAnsi(link):
  echo token.kind, ": ", token.value
```

OSC-8 hyperlinks terminated by BEL or ST are recognized.

### Terminal-cell layout

`displayWidth` measures cells rather than bytes or Unicode code points. It
handles combining marks, East Asian wide characters, variation selectors,
emoji modifiers, regional-indicator flags, and emoji joined with ZWJ. For
multiline strings it returns the widest line.

```nim
doAssert displayWidth("e\u0301") == 1
doAssert displayWidth("界") == 2
doAssert displayWidth("👨‍👩‍👧‍👦") == 2
```

Layout helpers retain active SGR styles and OSC-8 hyperlinks and never split a
wide or joined grapheme:

```nim
let value = bold("status: 界 ready")

echo sliceAnsi(value, startCell = 8, maxWidth = 4)
echo truncateAnsi(value, maxWidth = 12, suffix = "…")
echo "|", padAnsi(value, 24, alignCenter), "|"

for line in wrapAnsi(value, 10, wrapWords):
  echo line
```

![Cell-aware slicing, padding, and wrapping](docs/assets/terminal-cell-layout.png)

`sliceAnsi`, `truncateAnsi`, and `padAnsi` operate on one display line.
`wrapAnsi` honors explicit newlines and supports `wrapWords` and
`wrapCharacters`. Widths and offsets are validated early.

Terminal width conventions differ for a small number of ambiguous Unicode
characters and can be configured by individual terminal emulators. This
library uses the common narrow interpretation for ambiguous characters and a
two-cell interpretation for emoji.

## Modules

- `terminal_style/ansi` contains tokenization, stripping, and low-level ANSI
  composition.
- `terminal_style/colors` contains colors, attributes, styles, constants, and
  convenience helpers.
- `terminal_style/palettes` is an opt-in module containing reusable color
  palettes and re-exporting the color and style API.
- `terminal_style/widths` contains cell measurement, slicing, truncation,
  padding, and wrapping.
- `terminal_style` imports and exports ANSI, colors, and widths. Palette
  preset names remain opt-in.

Most applications should import only `terminal_style`; import
`terminal_style/palettes` when using palette presets.

## Examples

The finite showcase can be compiled directly while developing:

```sh
nim c -r examples/terminal_style.nim
```

## Development and documentation

```sh
nimble test
nimble examples
nimble docs
```

The generated [API documentation](https://titanomachy.github.io/terminal-style/)
is published by GitHub Actions after every push to `master`.

The example coverage audit is in [`docs/public-api.md`](docs/public-api.md).
Release history, contribution rules, third-party declarations, and the release
procedure live in `CHANGELOG.md`, `CONTRIBUTING.md`,
`THIRD_PARTY_NOTICES.md`, and `RELEASING.md`.

## Attribution and license
`terminal_style` contains original Nim code and incorporates no third-party
source code. It uses only the Nim standard library.

`terminal_style` is released under the [MIT License](https://github.com/titanomachy/terminal-style/blob/master/LICENSE).
