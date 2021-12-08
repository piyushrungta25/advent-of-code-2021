import std/setutils, tables, sequtils, strutils, algorithm

const segments = 'a'..'g'
const commonSegments = [5: "adg", 6: "abfg"]
const mapppings = ["abcefg", "cf", "acdeg", "acdfg", "bcdf", "abdfg", "abdefg",
        "acf", "abcdefg", "abcdfg"]
const reverse_mappings = {"abcefg": 0, "cf": 1, "acdeg": 2, "acdfg": 3,
        "bcdf": 4, "abdfg": 5, "abdefg": 6, "acf": 7, "abcdefg": 8,
        "abcdfg": 9}.toTable

proc part1(): int =
    for line in "input".lines:
        result += line.split(" | ")[^1].strip.split.filterIt(it.len in @[2, 4,
                3, 7]).len

proc reduce(possibilities: var array['a'..'g', set[char]]) =
    for i, p in possibilities:
        if p.len == 1:
            for j, q in possibilities:
                if i != j: possibilities[j] = q - p

proc decode(line: string): int =
    var possibilities: array['a'..'g', set[char]]
    for i in segments:
        possibilities[i] = segments.toSet

    let readings = line.strip.split.filterIt(it != "|")

    for reading in readings:
        if reading.len == 2: # 1
            for c in mapppings[1]:
                possibilities[c] = possibilities[c] * reading.toSet
        elif reading.len == 3: # 7
            for c in mapppings[7]:
                possibilities[c] = possibilities[c] * reading.toSet
        elif reading.len == 4: #4
            for c in mapppings[4]:
                possibilities[c] = possibilities[c] * reading.toSet
        elif reading.len == 5: # 2,3,5
            for i in commonSegments[5]:
                possibilities[i] = possibilities[i] * reading.toSet
        elif reading.len == 6: # 0,6,9
            for i in commonSegments[6]:
                possibilities[i] = possibilities[i] * reading.toSet

    # reduce
    while possibilities.anyIt(it.len != 1):
        reduce(possibilities)

    let decoded = newTable[char, char]()
    for i in segments:
        decoded[possibilities[i].toSeq[0]] = i

    var r = ""
    for i in readings[^4..^1]:
        let c: string = i.mapIt(decoded[it]).sorted.join
        r = r & $reverse_mappings[c]

    return parseInt(r)

proc part2(): int =
    for line in "input".lines:
        result += decode(line)

when isMainModule:
    echo part1()
    echo part2()
