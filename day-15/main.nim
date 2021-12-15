include ../imports
include ../gridUtils

type
    PathWeight = tuple
        endPoint: Point
        weight: int

proc `<`(a, b: PathWeight): bool =
    return a.weight < b.weight


proc parse(filename: string): Grid =
    collect:
        for line in filename.lines:
            line.mapIt(parseInt($it))


proc shortestPath(grid: Grid): int =
    let END: Point = grid.size - (1, 1)
    var weights: Table[Point, int] # minimum weight to reach this point from START
    var minPaths = initHeapQueue[PathWeight]() # list of candidate paths sorted by their current weight

    minPaths.push(((0, 0), 0))
    weights[(0, 0)] = 0

    while minPaths.len != 0:
        let curMinPath = minPaths.pop

        for p in grid.neighbors4(curMinPath.endPoint):
            if curMinPath.weight + grid[p] < weights.getOrDefault(p, high(int)):
                weights[p] = curMinPath.weight + grid[p]
                minPaths.push((p, weights[p]))

    return weights[END]


proc copyBlock(grid1: var Grid, grid2: Grid, si, sy: int) =
    for (i, j) in grid2.indices:
        grid1[i+si][j+sy] = grid2[i][j]

proc inc(grid: Grid): Grid =
    var ngrid = grid
    for (i, j) in ngrid.indices:
        ngrid[i][j] = ( (ngrid[i][j] + 1) mod 10)
        if ngrid[i][j] == 0: ngrid[i][j] = 1

    return ngrid

proc expandBy(grid: Grid, times: int): Grid =
    let (ix, iy) = grid.size
    let (nx, ny) = (ix*times, iy*times)

    var expanded = newSeqWith(times, newSeq[Grid](times))
    var ngrid = newSeqWith(nx, newSeq[int](ny))

    expanded[0][0] = grid

    # fill first row
    for i in 1..<times:
        expanded[0][i] = expanded[0][i-1].inc

    # fill rest of the rows
    for i in 1..<times:
        for j in 0..<times:
            expanded[i][j] = expanded[i-1][j].inc

    # merge everything
    for i, line in expanded:
        for j, grid in line:
            copyBlock(ngrid, grid, i*grid.len, j*grid[0].len)

    return ngrid

when isMainModule:
    let grid = parse("input")
    echo grid.shortestPath
    echo grid.expandBy(5).shortestPath
