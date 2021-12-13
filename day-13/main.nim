include ../imports

type
    Axis = enum
        X, Y
    Grid = object
        data: seq[seq[int]]
        size: (int, int)

    Instruction = (Axis, int)
    Instructions = seq[Instruction]


iterator indices(grid: Grid, si: int = 0, sj: int = 0): (int, int) =
    let (m, n) = grid.size
    for i in si..<m:
        for j in sj..<n:
            yield (i, j)


proc `$`(grid: Grid): string =
    let (m, n) = grid.size
    for i in 0..<m:
        for j in 0..<n:
            stdout.write (if grid.data[i][j] == 1: "█" else: " ")
        stdout.write '\n'


proc count(grid: Grid): int =
    for (i,j) in grid.indices:
        result += grid.data[i][j]

proc parseInput(filename: string): (Grid, Instructions) =
    let parts = filename.readFile.split("\n\n")
    let dots = parts[0]
    let instructions = parts[1]

    var
        maxx = low(int)
        maxy = low(int)

    let points = collect:
        for line in dots.splitLines:
            var (_, y, x) = line.scanTuple("$i,$i")
            maxx = max(x, maxx)
            maxy = max(y, maxy)
            (x, y)

    var grid: Grid
    grid.data = newSeqWith(maxx+1, newSeq[int](maxy+1))
    grid.size = (maxx+1, maxy+1)
    for (x, y) in points:
        grid.data[x][y] = 1

    let ins = collect:
        for line in instructions.splitLines:
            let (_, axis, l) = line.scanTuple("fold along $c=$i")
            if axis == 'x': (Y, l)
            else: (X, l)

    return (grid, ins)

proc foldX(grid: var Grid, l: int) =
    let (_, n) = grid.size
    for (i, j) in grid.indices(si = l+1):
        if grid.data[i][j] == 1:
            let ni = 2*l - i
            if ni < 0:
                break # only fold upward
            grid.data[ni][j] = 1

    grid.size = (l, n)

proc foldY(grid: var Grid, l: int) =
    let (m, _) = grid.size
    for (i, j) in grid.indices(sj = l+1):
        if grid.data[i][j] == 1:
            let nj = 2*l - j
            if nj < 0:
                break # only fold left
            grid.data[i][nj] = 1

    grid.size = (m, l)


proc fold(grid: var Grid, instruction: Instruction) =
    case instruction[0]:
        of X: grid.foldX(instruction[1])
        of Y: grid.foldY(instruction[1])

when isMainModule:
    var (grid, instructions) = parseInput("input")

    # part1
    grid.fold(instructions[0])
    echo "part1: ", grid.count

    #part2
    for i in instructions[1..^1]:
        grid.fold(i)

    echo grid
