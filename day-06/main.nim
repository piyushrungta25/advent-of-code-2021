import sequtils, strutils, tables

var cache = initTable[(int, int), int64]()

proc simulateRecursive(age: int, days: int): int64 =
    if (age, days) in cache: return cache[(age, days)]
    var cur_age = age
    result = 1
    
    for d in 1..days:
        if cur_age == 0:
            result += simulateRecursive(8, days-d)
        
        cur_age = if cur_age == 0: 6 else: cur_age - 1

    cache[(age, days)] = result

proc simulate(fishies: seq[int], days: int): int64 =
    for f in fishies:
        result += simulateRecursive(f, days)

when isMainModule:
    var input = "input".readFile.strip.split(",").map(parseInt)
    echo simulate(input, 80)
    echo simulate(input, 256)
