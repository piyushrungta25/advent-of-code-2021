import std/strutils
import std/sequtils
import std/sugar

proc parseInput(): seq =
    let f = open("input")
    defer: f.close()

    return f.lines.toSeq().map(x => parseInt(x))


proc part1(depths: var seq[int]): int =
    for i in 1..<depths.len:
        if depths[i-1] < depths[i]:
            result += 1

proc part2(depths: var seq[int]): int = 
    let window = 3
    for i in window..<depths.len:
        if depths[i-window] < depths[i]:
            result += 1

when isMainModule:
  var depths = parseInput()
  echo part1(depths)
  echo part2(depths)