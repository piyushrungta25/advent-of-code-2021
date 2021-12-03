import std/strutils
import std/math
import std/sugar
import std/sequtils

proc getCounts(numbers: seq[string]): array[12, int] =
    var counts: array['0'..'1', array[12, int]]
    for num in numbers:
        for i, c in num:
            inc(counts[c][i])

    for i in 0..11:
        if counts['1'][i] >= counts['0'][i]:
            result[i] = 1


proc part1(numbers: seq[string]): int =
    var gamma_rate, epsilon_rate: int
    var counts = numbers.getCounts

    for i in 0..11:
        var pow_2 = 2 ^ (11 - i)
        gamma_rate += pow_2 * counts[i]
        epsilon_rate += pow_2 * (1 - counts[i])

    return gamma_rate * epsilon_rate


proc filterAtPos(numbers: seq[string], c: int, pos: int): seq[string] =
    return numbers.filter(num => parseInt($num[pos]) == c)


proc part2(numbers: seq[string]): int =
    var oxy, co2 = numbers

    for i in 0..11:
        if oxy.len != 1:
            oxy = oxy.filterAtPos(oxy.getCounts[i], i)

        if co2.len != 1:
            co2 = co2.filterAtPos(1 - co2.getCounts[i], i)

    return oxy[0].parseBinInt * co2[0].parseBinInt


when isMainModule:
    var input = "./input".lines.toSeq
    echo part1(input)
    echo part2(input)
