include ../imports

type
    HeightMap = seq[seq[int]]
    Points = seq[(int, int)]

const directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]

proc parseInput(): HeightMap =
    result = collect:
        for line in "input".lines:
            line.mapIt(ord(it) - ord('0'))


proc outOfBounds(heightmap: HeightMap, k, l: int): bool =
    if k < 0 or k >= heightmap.len or l < 0 or l >= heightmap[0].len:
        return true


proc isLow(heightmap: HeightMap, i, j, k, l: int): bool =
    return heightmap.outOfBounds(k, l) or heightmap[i][j] < heightmap[k][l]


proc isLowPoint(heightmap: HeightMap, i, j: int): bool =
    result = true
    for (di, dj) in directions:
        result = result and isLow(heightmap, i, j, i+di, j+dj)


proc getLowPoints(heightmap: HeightMap): Points =
    for i, line in heightmap:
        for j, height in line:
            if heightmap.isLowPoint(i, j):
                result.add((i, j))


proc basinSize(heightmap: var HeightMap, i, j: int): int =
    if heightmap.outOfBounds(i, j) or heightmap[i][j] == 9 or heightmap[i][j] == -1:
        return 0

    let height = heightmap[i][j]
    heightmap[i][j] = -1

    var size = 1
    for (di, dj) in directions:
        let (k, l) = (i+di, j+dj)
        if not heightmap.outOfBounds(k, l) and heightmap[k][l] > height:
            size += heightmap.basinSize(k, l)

    return size


proc part1(heightmap: HeightMap, lowPoints: Points): int =
    return lowPoints.mapIt(heightmap[it[0]][it[1]]).foldl(a+b) + lowPoints.len


proc part2(heightmap: var HeightMap, lowPoints: Points): int =
    var maxBasinSizes = [low(int), low(int), low(int)].toHeapQueue
    for (i, j) in lowPoints:
        discard maxBasinSizes.pushpop(heightmap.basinSize(i, j))

    return maxBasinSizes.foldl(a*b)


when isMainModule:
    var heightmap = parseInput()
    let lowPoints = heightmap.getLowPoints
    echo heightMap.part1(lowPoints) == 439
    echo heightMap.part2(lowPoints) == 900900
