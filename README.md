# TerminalStyle

TerminalStyle is a dependency-free, pure-Nim library for terminal colors,
text attributes, ANSI parsing, and Unicode terminal-cell layout. Importing it
does not print, query the terminal, or modify global state.

`terminal_style` is the shared styling foundation for `terminal_graphs` and
`terminal_tables`, but can also be used independently.

Requires Nim 2.0.0 or newer.

## Colors and attributes

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

## Curated RGB palettes

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

<table style="border-collapse:collapse;">
  <thead>
    <tr>
      <th rowspan="2" bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">Slot</font></th>
      <th colspan="3" bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>defaultDarkPalette</tt> on <tt>#101418</tt></font></th>
      <th colspan="3" bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>defaultLightPalette</tt> on <tt>#F7F8FA</tt></font></th>
    </tr>
    <tr>
      <th bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">Swatch</font></th>
      <th bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">Value</font></th>
      <th bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">Contrast</font></th>
      <th bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">Swatch</font></th>
      <th bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">Value</font></th>
      <th bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">Contrast</font></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>black</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#101418" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#101418;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#101418</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">1.00:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#182028" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#182028;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#182028</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">15.49:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>red</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#EF6661" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#EF6661;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#EF6661</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">5.94:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#7C1117" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#7C1117;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#7C1117</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">10.14:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>green</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#46B250" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#46B250;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#46B250</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">6.82:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#015211" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#015211;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#015211</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">8.92:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>yellow</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#B99305" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#B99305;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#B99305</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">6.38:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#524001" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#524001;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#524001</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">9.44:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>blue</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#5696FF" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#5696FF;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#5696FF</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">6.34:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#0B3D8B" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#0B3D8B;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#0B3D8B</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">9.62:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>magenta</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#CB6FD1" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#CB6FD1;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#CB6FD1</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">5.93:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#651E6A" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#651E6A;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#651E6A</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">10.15:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>cyan</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#01ACBA" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#01ACBA;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#01ACBA</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">6.70:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#024C52" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#024C52;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#024C52</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">9.16:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>white</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#D5DDE5" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#D5DDE5;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#D5DDE5</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">13.48:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#E3E8ED" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#E3E8ED;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#E3E8ED</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">1.16:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightBlack</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#74818E" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#74818E;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#74818E</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">4.64:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#4D5966" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#4D5966;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#4D5966</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">6.73:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightRed</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#FFABA3" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#FFABA3;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#FFABA3</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">10.22:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#AC3031" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#AC3031;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#AC3031</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">6.13:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightGreen</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#81DD85" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#81DD85;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#81DD85</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">11.11:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#01791E" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#01791E;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#01791E</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">5.26:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightYellow</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#EABF3A" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#EABF3A;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#EABF3A</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">10.58:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#7A6001" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#7A6001;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#7A6001</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">5.64:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightBlue</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#A2C5FF" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#A2C5FF;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#A2C5FF</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">10.54:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#255EBC" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#255EBC;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#255EBC</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">5.80:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightMagenta</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#F5A1F9" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#F5A1F9;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#F5A1F9</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">10.00:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#8E3B94" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#8E3B94;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#8E3B94</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">6.17:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightCyan</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#00DDEF" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#00DDEF;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#00DDEF</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">11.09:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#02717A" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#02717A;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#02717A</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">5.42:1</font></td>
    </tr>
    <tr>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>brightWhite</tt></font></td>
      <td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><span title="#F5F7FA" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#F5F7FA;"></span></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF"><tt>#F5F7FA</tt></font></td><td bgcolor="#101418" style="background-color:#101418;border-bottom:1px solid #39424C;"><font color="#FFFFFF">17.24:1</font></td>
      <td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><span title="#F7F8FA" style="display:inline-block;width:24px;height:24px;margin:2px;border:1px solid #8C959F;border-radius:4px;background-color:#F7F8FA;"></span></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000"><tt>#F7F8FA</tt></font></td><td bgcolor="#EAEEF2" style="background-color:#EAEEF2;color:#000000;border-bottom:1px solid #CDD4DC;"><font color="#000000">1.00:1</font></td>
    </tr>
  </tbody>
</table>

See the [color palette guide](docs/color-palettes.md) for exact values,
contrast context, custom palettes, and guidance on choosing a preset.

## ANSI parsing

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

## Terminal-cell layout

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

## Example

The finite showcase can be compiled directly while developing:

```sh
nim c -r examples/terminal_style.nim
```

## Development

```sh
nimble test
nimble examples
nimble docs
```

The example coverage audit is in [`docs/public-api.md`](docs/public-api.md).
Release history, contribution rules, third-party declarations, and the release
procedure live in `CHANGELOG.md`, `CONTRIBUTING.md`,
`THIRD_PARTY_NOTICES.md`, and `RELEASING.md`.
