import std/[sequtils, strutils, unittest]

import terminal_style

suite "ANSI parsing":
  test "tokenizes complete CSI, OSC, and text losslessly":
    let value = "plain\e[31mred\e[0m " &
      "\e]8;;https://example.com\e\\link\e]8;;\e\\"
    let tokens = tokenizeAnsi(value)
    check tokens.len == 8
    check tokens[1].kind == atkCsi
    check tokens[5].kind == atkOsc
    check tokens.mapIt(it.value).join() == value
    check stripAnsi(value) == "plainred link"
    check stripAnsi("\e]0;window title\aok") == "ok"

  test "retains malformed and unterminated escapes as text":
    for malformed in ["before\e", "before\e[31", "before\e]8;;url"]:
      check stripAnsi(malformed) == malformed

  test "restores an outer style after nested resets":
    let nested = bold("before ", red("alert"), " after")
    check nested == termBold & "before " & termRed & "alert" & termClear &
      termBold & " after" & termClear
    check stripAnsi(nested) == "before alert after"
    check composeAnsi(termBold, "a\e[1;0mb") ==
      termBold & "a\e[1;0m" & termBold & "b" & termClear

suite "terminal colors and styles":
  test "constructs standard, indexed, RGB, and hexadecimal colors":
    check ansiCode(colorBrightRed) == termBrightRed
    check ansiCode(colorBlue, cpBackground) == termBgBlue
    check ansiCode(indexedColor(208)) == "\e[38;5;208m"
    check ansiCode(indexedColor(17), cpBackground) == "\e[48;5;17m"
    check ansiCode(rgbColor(12, 34, 56)) == "\e[38;2;12;34;56m"
    check ansiCode(hexColor("#0c2238")) == "\e[38;2;12;34;56m"
    check hexColor("#abc") == rgbColor(170, 187, 204)
    expect ValueError:
      discard hexColor("#12")
    expect ValueError:
      discard hexColor("#gg0000")

  test "combines reusable colors and attributes":
    let textStyle = initTerminalStyle(
      foreground = rgbColor(120, 200, 255),
      background = indexedColor(17),
      attributes = {taBold, taUnderline}
    )
    check ansiCode(textStyle) == "\e[1;4;38;2;120;200;255;48;5;17m"
    check styled(textStyle, "jobs: ", 3) ==
      ansiCode(textStyle) & "jobs: 3" & termClear

  test "preserves color components in palettes":
    let palette = @[colorBrightCyan, colorBrightRed, indexedColor(208),
      rgbColor(12, 34, 56)]
    check palette.mapIt(ansiCode(it)) ==
      @[termBrightCyan, termBrightRed, "\e[38;5;208m", "\e[38;2;12;34;56m"]

  test "supports concise helpers and disabled output":
    check red("alert ", 42) == termRed & "alert 42" & termClear
    check onIndexed(235, "panel") == "\e[48;5;235mpanel" & termClear
    check rgb(1, 2, 3, "pixel") == "\e[38;2;1;2;3mpixel" & termClear
    let decorated = red("failure")
    let textStyle = initTerminalStyle(attributes = {taBold})
    check applyStyle(decorated, textStyle, enabled = false) == "failure"

suite "terminal cell layout":
  test "measures combining, East Asian, variation, and emoji sequences":
    check displayWidth("e\u0301") == 1
    check displayWidth("界") == 2
    check displayWidth("❤") == 1
    check displayWidth("❤️") == 2
    check displayWidth("👨‍👩‍👧‍👦") == 2
    check displayWidth("🇳🇱") == 2
    check displayWidth("short\n界界界") == 6

  test "slices without splitting graphemes and restores style":
    let value = bold("A界B")
    let sliced = sliceAnsi(value, 1, 2)
    check stripAnsi(sliced) == "界"
    check sliced.startsWith(termBold)
    check sliced.endsWith(termClear)
    check sliceAnsi(value, 2, 1) == ""

  test "preserves OSC hyperlinks while slicing":
    let link = "\e]8;;https://example.com\e\\docs\e]8;;\e\\"
    let sliced = sliceAnsi(link, 1, 2)
    check stripAnsi(sliced) == "oc"
    check sliced.startsWith("\e]8;;https://example.com\e\\")
    check sliced.endsWith("\e]8;;\e\\")
    check sliceAnsi(link & " tail", 5, 4) == "tail"

  test "truncates and pads by cells":
    check stripAnsi(truncateAnsi(red("A界BC"), 4)) == "A界…"
    check displayWidth(truncateAnsi(red("A界BC"), 4)) == 4
    check padAnsi("界", 6, alignLeft) == "界    "
    check padAnsi("界", 6, alignCenter) == "  界  "
    check padAnsi("界", 6, alignRight) == "    界"

  test "wraps words, graphemes, explicit lines, and active styles":
    let words = wrapAnsi(bold("red green blue"), 6)
    check words.mapIt(stripAnsi(it)) == @["red", "green", "blue"]
    check words.allIt(it.startsWith(termBold) and it.endsWith(termClear))
    let characters = wrapAnsi("A界BC", 3, wrapCharacters)
    check characters == @["A界", "BC"]
    check wrapAnsi("one\ntwo", 8) == @["one", "two"]
    check wrapAnsi("   ", 3) == @[""]

  test "validates layout dimensions":
    expect ValueError:
      discard sliceAnsi("text", -1, 2)
    expect ValueError:
      discard truncateAnsi("text", -1)
    expect ValueError:
      discard padAnsi("text", 8, padding = '\t')
    expect ValueError:
      discard wrapAnsi("text", 0)
