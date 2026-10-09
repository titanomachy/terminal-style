## Shared SGR reset parsing for composition and layout.

import std/strutils

proc sgrResetTail*(sequence: string): tuple[hasReset: bool, trailing: string] =
  ## Finds the last full reset and the SGR parameters that follow it.
  ## Extended-color arguments belong to their color command, even when zero.
  let parameters = sequence[2 ..< sequence.high].split(';')
  var index = 0
  var afterReset = 0
  while index < parameters.len:
    let parameter = parameters[index]
    inc index
    if parameter.len == 0 or parameter.allCharsInSet({'0'}):
      result.hasReset = true
      afterReset = index
    elif parameter in ["38", "48", "58"] and index < parameters.len:
      case parameters[index]
      of "2":
        # Color mode followed by three RGB channels.
        index = min(parameters.len, index + 4)
      of "5":
        # Color mode followed by one palette index.
        index = min(parameters.len, index + 2)
      else:
        discard
  if result.hasReset and afterReset < parameters.len:
    result.trailing = "\e[" & parameters[afterReset .. ^1].join(";") & "m"
