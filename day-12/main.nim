include ../imports

type
    Inode = object
        label: string
        isVisited: bool
        isBig: bool
        isSmall: bool
        isStart: bool
        isEnd: bool

    Node = ref Inode

    Edge = (Node, Node)

    Path = seq[Node]

    Graph = Table[Node, seq[Node]]

const START = "start"
const END = "end"

proc hash(node: Node): Hash = node.label.hash
proc hash(path: Path): Hash = path.mapIt(it.label).join.hash
proc `==`(node1, node2: Node): bool = node1.label == node2.label
proc `==`(path1, path2: Path): bool =
    if path1.len != path2.len: return false
    for i in 0..<path1.len:
        if path1[i] != path2[i]:
            return false
    return true

proc `$`(node: Node): string = fmt"({node.label})"
proc `$`(edge: Edge): string = fmt"{edge[0]} -> {edge[1]}"
proc `$`(nodes: seq[Node]): string = nodes.join(", ")
proc `$`(edges: seq[Edge]): string = edges.join(", ")

proc newNode(label: string): Node =
    new(result)
    result.label = label
    result.isBig = label.allIt(it in 'A'..'Z')
    result.isSmall = label.allIt(it in 'a'..'z')
    result.isStart = label == START
    result.isEnd = label == END


var nodes: Table[string, Node]

proc makeGraph(filename: string): Graph =
    for line in filename.lines:
        let (_, a, b) = line.scanTuple("$+-$+")

        let nodea = nodes.mgetOrPut(a, a.newNode)
        let nodeb = nodes.mgetOrPut(b, b.newNode)
        result.mgetOrPut(nodea, @[]).add(nodeb)
        result.mgetOrPut(nodeb, @[]).add(nodea)


proc canVisitPart1(frm, to: Node, visited_edges: seq[Edge], visitedNodes: seq[Node]): bool =
    if visited_edges.contains((frm, to)):
        return false

    if to.isSmall and to in visited_nodes:
        return false

    return true


proc visit(graph: var Graph, visited_edges: var seq[Edge],
        visited_nodes: var seq[Node], cur_node: var Node): int =
    visited_nodes.add cur_node
    for neighbour in graph[cur_node].mitems:
        if neighbour.isEnd:
            result += 1
        elif canVisitPart1(cur_node, neighbour, visitedEdges, visitedNodes):
            visited_nodes.add neighbour
            visited_edges.add ((cur_node, neighbour))
            result += visit(graph, visited_edges, visited_nodes, neighbour)
            discard visited_edges.pop
            discard visited_nodes.pop

    discard visited_nodes.pop


proc part1(graph: var Graph): int =
    var
        visited: seq[Edge]
        visitedNodes: seq[Node]
    result = visit(graph, visited, visitedNodes, nodes[START])



var hasVisitedTwice: bool = false
var paths: OrderedSet[Path]


proc canVisitPart2(frm, to: Node, visited_edges: seq[Edge], visitedNodes: seq[
        Node], tn: Node): (bool, bool) =
    var canVisit = canVisitPart1(frm, to, visited_edges, visitedNodes)
    if canVisit: return (true, false)

    if to == tn or (frm == tn and to.isBig):
        return (false, true)

    return (false, false)


proc visit2(graph: var Graph,
            visited_edges: var seq[Edge],
            visited_nodes: var seq[Node],
            cur_node: var Node,
            tn: Node) =
    visited_nodes.add cur_node
    for neighbour in graph[cur_node].mitems:
        if neighbour.isEnd:
            var path = visited_nodes
            path.add(neighbour)
            paths.incl(path)
        else:
            let (normal, twice) = canVisitPart2(cur_node, neighbour,
                    visitedEdges, visitedNodes, tn)
            if normal or (twice and cur_node == tn and neighbour.isBig):
                visited_edges.add ((cur_node, neighbour))
                visit2(graph, visited_edges, visited_nodes, neighbour, tn)
                discard visited_edges.pop
            elif twice and hasVisitedTwice == false:
                hasVisitedTwice = true
                visited_edges.add ((cur_node, neighbour))
                visit2(graph, visited_edges, visited_nodes, neighbour, tn)
                discard visited_edges.pop
                hasVisitedTwice = false

    discard visited_nodes.pop


proc part2(graph: var Graph): int =
    var smallNodes = collect:
        for k in nodes.keys:
            if k.allIt(it in 'a'..'z') and k != START and k != END:
                nodes[k]

    for tn in smallNodes:
        var
            visited: seq[Edge]
            visitedNodes: seq[Node]

        hasVisitedTwice = false
        visit2(graph, visited, visitedNodes, nodes[START], tn)

    return paths.len

var graph = makeGraph("input")
echo part1(graph) == 3410
echo part2(graph) == 98796
