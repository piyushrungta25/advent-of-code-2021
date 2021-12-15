include imports

type
    Grid = seq[seq[int]]
    Point = tuple
        x, y: int

const deltas4: seq[Point] = @[
    (1, 0), (0, 1), (-1, 0), (0, -1),
]

const deltas8: seq[Point] = @[
    (1, 0), (0, 1), (1, 1), (-1, -1), (1, -1), (-1, 1), (-1, 0), (0, -1),
]


proc `+`(a, b: Point): Point = (a.x+b.x, a.y+b.y)
proc `-`(a, b: Point): Point = (a.x-b.x, a.y-b.y)

proc size(grid: Grid): (int, int) =
    return (grid.len, grid[0].len) # assuming grid not empty

proc inside(grid: Grid, point: Point): bool =
    let (m, n) = grid.size
    let (x, y) = point
    return x >= 0 and y >= 0 and x < m and y < n

iterator neighbors(grid: Grid, point: Point, deltas: seq[Point]): Point =
    for dp in deltas:
        let newPoint = point + dp
        if grid.inside(newPoint):
            yield newPoint

iterator neighbors4(grid: Grid, point: Point): Point =
    for p in grid.neighbors(point, deltas4):
        yield p

iterator neighbors8(grid: Grid, point: Point): Point =
    for p in grid.neighbors(point, deltas8):
        yield p

iterator indices(grid: Grid, si: int = 0, sj: int = 0): Point =
    let (m, n) = grid.size
    for i in si..<m:
        for j in sj..<n:
            yield (i, j)

proc `$`(grid: Grid): string =
    for line in grid:
        result &= line.mapIt($it).join(" ")
        result &= "\n"

proc `[]`(grid: Grid, point: Point): int =
    grid[point.x][point.y]
