include ../imports

type
    Grid = seq[seq[int]]

const deltas: seq[(int, int)] = @[
    (1, 0), (0, 1), (1, 1), (-1, -1), (1, -1), (-1, 1), (-1, 0), (0, -1),
]

proc size(grid: Grid): (int, int) =
    return (grid.len, grid[0].len) # assuming grid not empty


iterator neighbors(grid: Grid, i, j: int): (int, int) =
    let (m, n) = grid.size
    for (di, dj) in deltas:
        var (k, l) = (i+di, j+dj)
        if k >= 0 and l >= 0 and k < m and l < n:
            yield (k, l)


iterator indices(grid: Grid): (int, int) =
    let (m, n) = grid.size
    for i in 0..<m:
        for j in 0..<n:
            yield (i, j)


proc increment(grid: var Grid, i, j: int) =
    grid[i][j] += 1
    if grid[i][j] == 10: # each octo can flash only once
        for (k, l) in grid.neighbors(i, j):
            grid.increment(k, l)


proc step(grid: var Grid): int =
    for (i, j) in grid.indices:
        grid.increment(i, j)

    for (i, j) in grid.indices:
        if grid[i][j] > 9:
            result += 1
            grid[i][j] = 0


proc solve(grid: var Grid, min_steps: int): (int, int) =
    var part1, part2: int

    for i in 0..high(int):
        let flashes = grid.step
        if flashes == 100:
            part2 = i+1
        if i < min_steps:
            part1 += flashes

        if i >= min_steps and part2 != 0:
            break

    return (part1, part2)


when isMainModule:
    var grid: Grid = collect:
        for line in "input".lines:
            line.mapIt(parseInt($it))
    
    echo grid.solve(100)
