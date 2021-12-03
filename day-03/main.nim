import std/strutils
import std/math

proc parseInput(): seq[string] =
    return open("input").readAll.splitLines

proc part1(numbers: seq[string]): int =
    var gamma_rate, epsilon_rate: int
    var counts: array['0'..'1', array[0..11, int]]

    for num in numbers:
        for i, c in num:
            inc(counts[c][i])

    for i in 0..11:
        if counts['1'][i] > counts['0'][i]:
            gamma_rate += (2 ^ (11-i) * 1)
        else:
            epsilon_rate += (2 ^ (11-i) * 1)

    return gamma_rate * epsilon_rate




when isMainModule:
    var instructions = parseInput()
    echo part1(instructions)
