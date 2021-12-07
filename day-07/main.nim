import sugar, sequtils, math, strutils

proc part1(positions: seq[int]): int =
    let costs = collect:
        for i in positions.min..positions.max:
            positions.mapIt(abs(i-it)).sum

    return costs.min

proc part2(positions: seq[int]): int =
    let best = (positions.sum/positions.len).floor.int
    return positions.map(x => (x-best).abs).map(x => x*(x+1)/2).sum.int

when isMainModule:
    let positions = "input".readFile.strip.split(",").map(parseInt)
    echo part1(positions)
    echo part2(positions)
