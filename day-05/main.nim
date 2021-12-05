import strscans, sugar, math, sequtils

type
    Point = tuple[x, y: int]
    Line = tuple[p1, p2: Point]
    Grid = seq[seq[int]]

proc newGrid(x, y: int): Grid = newSeqWith(x+1, newSeq[int](y+1))

proc parseInput(): (Grid, seq[Line]) =
    const INPUT_PATTERN = "$i,$i -> $i,$i"
    var max_x, max_y = low(int)

    let lines: seq[Line] = collect:
        for line in "input".lines:
            var (_, y1, x1, y2, x2) = line.scanTuple(INPUT_PATTERN)
            max_x = max(max(x1, x2), max_x)
            max_y = max(max(y1, y2), max_y)
            ((x1, y1), (x2, y2))

    let grid: Grid = newGrid(max_x, max_y)

    return (grid, lines)

proc isDiagonal(line: Line): bool = not (line.p1.x == line.p2.x or line.p1.y == line.p2.y)
proc norm(x: int): int = return if x == 0: 0 elif x > 0: 1 else: -1

proc plot(grid: var Grid, line: Line) =
    let slopeX = (line.p2.x - line.p1.x).norm
    let slopeY = (line.p2.y - line.p1.y).norm

    var (x, y) = line.p1
    grid[x][y] += 1
    while x != line.p2.x or y != line.p2.y:
        x += slopeX
        y += slopeY
        grid[x][y] += 1

proc plotIfDiagonal(grid: var Grid, line: Line) =
    if line.isDiagonal: grid.plot(line)

proc plotIfStraight(grid: var Grid, line: Line) =
    if not line.isDiagonal: grid.plot(line)

proc countIntersections(grid: Grid): int =
    return grid.map(row => row.filterIt(it > 1).len).sum

proc part1(grid: var Grid, lines: seq[Line]): int =
    for line in lines: grid.plotIfStraight(line)
    return grid.countIntersections()

proc part2(grid: var Grid, lines: seq[Line]): int =
    for line in lines: grid.plotIfDiagonal(line)
    return grid.countIntersections()

when isMainModule:
    var (grid, lines) = parseInput()
    echo part1(grid, lines)
    echo part2(grid, lines)
