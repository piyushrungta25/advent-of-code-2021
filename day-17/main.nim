include ../imports

let
    (_, x1, x2, y2, y1) = "input".readFile.strip.scanTuple("target area: x=$i..$i, y=$i..$i")

var globalMaxY = low(int)

proc inTarget(x, y: int): bool =
    return x >= x1 and x <= x2 and y >= y2 and y <= y1

proc isCandidate(vxx, vyy: int): bool =
    var
        x, y = 0
        vx = vxx
        vy = vyy
        maxy = low(int)

    while x <= x2 and y >= y2:
        maxy = max(maxy, y)
        if inTarget(x, y):
            globalMaxY = max(globalMaxY, maxy)
            return true
        x += vx
        y += vy

        vy -= 1
        if vx > 0: vx -= 1

    return false



var candidates: int

for vx in 0..x2:
    for vy in y2..(-y2-1):
        if isCandidate(vx, vy):
            candidates.inc

echo globalMaxY
echo candidates
