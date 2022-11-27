include ../imports
include ../utils

var consoleLog = newConsoleLogger(
    fmtStr = "",
    levelThreshold = lvlError
    # levelThreshold=lvlDebug
)
addHandler(consoleLog)

type
    Point = tuple
        x, y, z: int

    Offest = Point

    Sensor = ref object
        label: int
        position: Point
        lasttransform: (Orientation, Offest)
        beacons: seq[Point]

    Orientation = tuple
        p1, p2, p3, r1, r2, r3: int


func `+`(p1, p2: Point): Point =
    (p1.x + p2.x, p1.y+p2.y, p1.z+p2.z)

func `-`(p1, p2: Point): Point =
    (p1.x - p2.x, p1.y-p2.y, p1.z-p2.z)

func hash(sensor: Sensor): Hash = hash(cast[int](sensor))

# func `$`(sensor: Sensor): string =
#     result &= "---- sensor start ----\n"
#     for b in sensor.beacons:
#         result &= indent(fmt"{b.x},{b.y},{b.z}", 4) & "\n"
#     result &= "---- sensor end ----"

func `$`(sensor: Sensor): string = $sensor.label

const orientations = [
    (0, 1, 2, 1, 1, 1),
    (0, 1, 2, -1, -1, 1),
    (0, 1, 2, -1, 1, -1),
    (0, 1, 2, 1, -1, -1),

    (1, 0, 2, -1, 1, 1),
    (1, 0, 2, 1, -1, 1),
    (1, 0, 2, 1, 1, -1),
    (1, 0, 2, -1, -1, -1),

    (0, 2, 1, 1, -1, 1),
    (0, 2, 1, -1, -1, -1),
    (0, 2, 1, 1, 1, -1),
    (0, 2, 1, -1, 1, 1),

    (1, 2, 0, -1, -1, 1),
    (1, 2, 0, 1, -1, -1),
    (1, 2, 0, -1, 1, -1),
    (1, 2, 0, 1, 1, 1),

    (2, 1, 0, -1, 1, 1),
    (2, 1, 0, -1, -1, -1),
    (2, 1, 0, 1, 1, -1),
    (2, 1, 0, 1, -1, 1),

    (2, 0, 1, -1, 1, -1),
    (2, 0, 1, -1, -1, 1),
    (2, 0, 1, 1, 1, 1),
    (2, 0, 1, 1, -1, -1),
]


func rotate(p: Point, o: Orientation): Point =
    let (p1, p2, p3, r1, r2, r3) = o
    let points = [p.x, p.y, p.z]
    return (points[p1]*r1, points[p2]*r2, points[p3]*r3)

func rrotate(p: Point, o: Orientation): Point =
    let (p1, p2, p3, r1, r2, r3) = o
    let points = [p.x*r1, p.y*r2, p.z*r3]
    return (points[p1], points[p2], points[p3])


func rotate(s: Sensor, o: Orientation): Sensor =
    var transformed = Sensor()
    transformed.beacons = s.beacons.mapIt(it.rotate(o))
    return transformed

func offset(sensor: Sensor, offset: Offest): Sensor =
    var offestted = Sensor()
    offestted.beacons = sensor.beacons.map(p => p+offset)
    return offestted

func offset(point: Point, offset: Offest): Point =
    return point + offset



proc transform(p: Point, o: Orientation, off: Offest): Point =
    return p.rotate(o).offset(off)



proc transform(p: Sensor, o: Orientation, off: Offest): Sensor =
    return p.rotate(o).offset(off)


iterator sensorOrientations(sensor: Sensor): Sensor =
    for orientation in orientations:
        var rotated = Sensor()
        rotated.beacons = sensor.beacons.mapIt(it.rotate(orientation))
        yield rotated


func count(s1, s2: Sensor): int =
    intersection(s1.beacons.toHashSet, s2.beacons.toHashSet).len

proc isRelated(s1, s2: Sensor, minCount: int = 12): Option[(Orientation, Offest)] =
    # assuming s1 as the source of truth
    for orientation in orientations:
        debug("trying orientation: ", orientation)
        var ts2 = s2.rotate(orientation)
        debug("after transform:")
        debug($ts2)
        for p1 in s1.beacons:
            for p2 in ts2.beacons:
                debug("taking points ", p1, p2)
                let coff = p1-p2
                # offsetsGlobal.add (p2-p1)
                debug("coff: ", coff)
                let ots2 = ts2.offset(coff)
                debug("after offset: ", ots2)
                var count = count(s1, ots2)
                debug("count: ", count)
                if count >= minCount:
                    s2.position = s1.position - coff
                    return some((orientation, coff))

proc findRelations(sensors: seq[Sensor]): (Table[Sensor, HashSet[Sensor]],
        Table[(Sensor, Sensor), (Orientation, Offest)]) =
    let n = sensors.len
    var dag: Table[Sensor, HashSet[Sensor]] # Sensor 1 and 2 have more than 12 common points
    var transParams: Table[(Sensor, Sensor), (Orientation,
            Offest)] # to transform S1 -> S2, rotate by Orientation and offset by Point

    var numEdges: int # to stop the search once we have a complete DAG


    block outer:
        for i in 0..<(n-1):
            for j in (i+1)..<n:
                # echo "trying", (i, j)
                let (s1, s2) = (sensors[i], sensors[j])
                debug($s1)
                debug($s2)
                let transPara = isRelated(s1, s2)
                if transPara.isSome:
                    echo "found", (i, j)
                    debug("can be transformed: para", transPara.get)
                    numEdges += 1
                    dag.mgetOrPut(s1, initHashSet[Sensor]()).incl(s2)
                    dag.mgetOrPut(s2, initHashSet[Sensor]()).incl(s1)

                    transParams[(s1, s2)] = transPara.get
                    transParams[(s2, s1)] = isRelated(s2, s1).get

                if numEdges == (n-1): # we have a DAG, enough to fold all sensors in one
                    echo "breaking"
                    break outer


    return (dag, transParams)


proc parseInput(filename: string = "input_small"): seq[Sensor] =
    for i, data in filename.readFile.split("\n\n").toSeq:
        let points = data.split("\n")[1..^1]
        var sensor = Sensor(label: i)
        sensor.beacons = collect:
            for point in points:
                let (_, x, y, z) = point.scanTuple("$i,$i,$i")
                (x, y, z)

        result.add sensor

proc toposort[T](deps: Table[T, HashSet[T]], root: T, transMap: Table[(Sensor, Sensor), (Orientation, Offest)]): seq[T] =
    var visited: HashSet[T]
    var updatedPos: HashSet[T]
    proc irec[T](deps: Table[T, HashSet[T]], curNode: T, fl: var seq[T], transMap: Table[(Sensor, Sensor), (Orientation, Offest)]) =
        if curNode in visited:
            return
        visited.incl curNode

        for nbrs in deps[curNode]:
            if not updatedPos.contains(nbrs):
                let (o, off) = transMap[(curNode, nbrs)]

                nbrs.position = curNode.position + off.rrotate(curNode.lasttransform[0])
                nbrs.lasttransform = (o, off)

                updatedPos.incl nbrs   
            irec(deps, nbrs, fl, transMap)
        fl.add curNode
    
    root.lasttransform = ((0,1,2,1,1,1), (0,0,0))
    updatedPos.incl root
    irec(deps, root, result, transMap)


proc solve() =
    # let s = parseInput()
    let s = parseInput("input")

    var (deps, transMap) = findRelations(s)

    var toposorted = toposort(deps, s[0], transMap)

    # for (k, v) in transMap.pairs:
    #     echo k, " ", v
    assert toposorted[^1] == s[0]


    # reduce
    for ntr in toposorted[0..^2]:
        var pl = deps[ntr]
        var p = pl.toSeq[0]
        let (o, off) = transMap[(p, ntr)]
        p.beacons = union(ntr.transform(o, off).beacons.toHashSet,
                p.beacons.toHashSet).toSeq

        for dd in deps[ntr]:
            deps.mgetorput(dd, initHashSet[Sensor]()).excl ntr
        deps.del ntr

    echo "part1: ", toposorted[^1].beacons.len

    var maxmand = low(int)

    # let points = s[0].beacons
    let n = s.len
    for i in 0..<n:
        for j in 0..<n:
            if i!=j:
                let s1 = s[i].position
                let s2 = s[j].position

                let mand = abs(s1.x-s2.x) + abs(s1.y-s2.y) + abs(s1.z-s2.z)
                maxmand = max(mand, maxmand)


    echo "part2: ", maxmand
    # echo s[2].transforms



solve()

when false:
# when true:

    suite "Rotations":
        test "point rotation":
            check:
                (1, 1, 1).rotate(orientations[0]) == (1, 1, 1)
                (1, 1, 1).rotate(orientations[1]) == (-1, -1, 1)
        test "sensor rotation":
            let sensor = Sensor(beacons: @[(1, 1, 1)])
            check:
                sensorOrientations(sensor).toSeq[0].beacons == @[(1, 1, 1)]
                sensorOrientations(sensor).toSeq[1].beacons == @[(-1, -1, 1)]
        test "offset":
            check:
                Sensor(beacons: @[(1, 1, 1)]).offset((1, 2, 3)).beacons[0] == (
                        2, 3, 4)
        test "parsing":
            check:
                parseInput().len == 5
                parseInput()[1].beacons[0] == (686, 422, 578)
        test "relation simple":
            let s1 = Sensor(beacons: @[(1, 1, 1), (2, 2, 2)])
            let s2 = Sensor(beacons: @[(-1, 1, -1), (-2, 2, -2)])

            check:
                isRelated(s1, s2, 2).isSome == true
        test "relation big":
            let (s1, s2) = (parseInput()[0], parseInput()[1])
            check:
                isRelated(s1, s2).isSome == true
                isRelated(s1, s2).get()[0] == (0, 1, 2, -1, 1, -1)
                isRelated(s1, s2).get()[1] == (68, -1246, -43)
        test "relation more":
            let s = parseInput()
            let (s1, s2) = (s[1], s[4])
            check:
                isRelated(s1, s2).isSome == true
                isRelated(s2, s1).isSome == true
        test "toposort":
            let deps: Table[int, HashSet[int]] = [(0, [1].toHashSet), (1, [3,
                    4].toHashSet), (2, [4].toHashSet), (3, [1].toHashSet), (4, [
                    1, 2].toHashSet)].toTable
            check:
                toposort(deps, 0) == [3, 2, 4, 1, 0]
        test "relation":
            let s = parseInput("input")
            check:
                isRelated(s[7], s[14]).isSome == true
                isRelated(s[14], s[7]).isSome == true









