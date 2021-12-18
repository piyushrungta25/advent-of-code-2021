include ../imports
include ../utils

type
    NodeType = enum
        Pair, Leaf

    Node = ref object
        case nodeType: NodeType
            of Pair:
                left, right: Node
            of Leaf:
                value: int

# Alternate representation, helpful to debug single expressions
#
# proc `$`(node: Node): string =
#     case node.nodeType:
#         of Leaf: return fmt"Leaf: {node.value}"
#         of Pair:
#             result = "Pair:\n" & indent($node.left, 2) & '\n' & indent($node.right, 2)

proc `$`(node: Node): string =
    case node.nodeType:
        of Leaf: fmt"{node.value}"
        of Pair: fmt"[{$node.left},{$node.right}]"


func leafNode(value: int): Node = Node(nodeType: Leaf, value: value)
func pairNode(left, right: Node): Node = Node(nodetype: Pair, left: left, right: right)
func pairNode(left, right: int): Node = Node(nodeType: Pair, left: leafNode(
        left), right: leafNode(right))
func add(node1, node2: Node): Node = pairNode(node1, node2)


proc parseInternal(str: string, idx: int = 0): (Node, int) =
    var curIdx = idx
    case str[idx]:
        of '[':
            var node = Node(nodeType: Pair)
            (node.left, curIdx) = parseInternal(str, curIdx+1)
            (node.right, curIdx) = parseInternal(str, curIdx+1)
            return (node, curIdx+1)
        of ',': return parseInternal(str, curIdx+1)
        of '0'..'9': return (leafNode(parseInt($str[idx])), idx+1)
        else: raise newException(ValueError, "bad input")


proc parse(str: string): Node = parseInternal(str)[0]


proc magnitude(node: Node): int =
    case node.nodeType:
        of Leaf:
            return node.value
        of Pair:
            return 3*magnitude(node.left) + 2*magnitude(node.right)


proc inorder(node, target: Node, result1: var seq[Node]) =
    case node.nodeType:
        of Leaf: result1.add node
        of Pair:
            inorder(node.left, target, result1)
            inorder(node.right, target, result1)


proc leftLeafOf(target: Node, nodes: seq[Node]): Option[Node] =
    for node in nodes:
        if node == target: return result
        if node.nodeType == Leaf: result = some(node)


proc rightLeafOf(target: Node, nodes: seq[Node]): Option[Node] =
    for i in countdown(nodes.len-1, 0):
        if nodes[i] == target: return result
        if nodes[i].nodeType == Leaf: result = some(nodes[i])


proc neighbors(root: Node, target: Node): (Option[Node], Option[Node]) =
    var nodes: seq[Node]
    inorder(root, target, nodes)

    result[0] = leftLeafOf(target.left, nodes)
    result[1] = rightLeafOf(target.right, nodes)


proc explode(root, target: Node): Node =
    let (left, right) = root.neighbors(target)

    if left.isSome: left.get().value += target.left.value
    if right.isSome: right.get().value += target.right.value

    return leafNode(0)


proc split(node: Node): Node =
    let half = node.value/2
    return pairNode(half.floor.int, half.ceil.int)


proc explodeCandidate(node: Node, depth: int = 0): Option[(Node, Node)] =
    if node.nodetype == Leaf: return none((Node, Node))

    if depth == 3:
        if node.left.nodeType == Pair:
            return some((node, node.left))
        if node.right.nodeType == Pair:
            return some((node, node.right))

    let left = explodeCandidate(node.left, depth+1)
    if left.isSome: return left


    let right = explodeCandidate(node.right, depth+1)
    if right.isSome: return right

    return none((Node, Node))


proc splitCandidate(node: Node): Option[(Node, Node)] =
    if node.nodetype == Leaf: return none((Node, Node))

    if node.left.nodeType == Leaf and node.left.value > 9:
        return some((node, node.left))

    let left = splitCandidate(node.left)
    if left.isSome: return left

    if node.right.nodeType == Leaf and node.right.value > 9:
        return some((node, node.right))

    let right = splitCandidate(node.right)
    if right.isSome: return right

    return none((Node, Node))


proc reduce(root: Node): Node =
    while true:
        let ec = explodeCandidate(root)
        if ec.isSome:
            let (parent, child) = ec.get()
            if parent.left == child:
                parent.left = explode(root, child)
            else:
                parent.right = explode(root, child)
            continue

        let sc = splitCandidate(root)
        if sc.isSome:
            let (parent, child) = sc.get()
            if parent.left == child:
                parent.left = split(child)
            else:
                parent.right = split(child)
            continue

        break

    return root


proc addAndReduce(node1, node2: Node): Node =
    result = node1.add(node2)
    result = reduce(result)


proc `+`(a, b: Node): Node =
    return addAndReduce(a, b)


proc getSum(filename: string): Node =
    filename.readFile.split.map(parse).foldl(a + b)



proc getMaximumMagnitude(filename: string): int =
    let nums = filename.readFile.split
    let n = nums.len

    for i in 0..<(n-1):
        for j in (i+1)..<n:
            result = max(result, (nums[i].parse + nums[j].parse).magnitude)
            result = max(result, (nums[j].parse + nums[i].parse).magnitude)


echo "part1: ", getSum("input").magnitude
echo "part2: ", getMaximumMagnitude("input")


when false:
    suite "Tests":
        test "Magnitudes":
            check:
                "[1,1]".parse.magnitude == 5
                "[[1,2],[[3,4],5]]".parse.magnitude == 143
                "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]".parse.magnitude == 1384
                "[[[[1,1],[2,2]],[3,3]],[4,4]]".parse.magnitude == 445
                "[[[[3,0],[5,3]],[4,4]],[5,5]]".parse.magnitude == 791
                "[[[[5,0],[7,4]],[5,5]],[6,6]]".parse.magnitude == 1137
                "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]".parse.magnitude == 3488

        test "Addition":
            check:
                $add("[1,1]".parse, "[1,1]".parse) == "[[1,1],[1,1]]"
                $add("[1,2]".parse, "[[3,4],5]".parse) == "[[1,2],[[3,4],5]]"
                $addAndReduce("[[[[4,3],4],4],[7,[[8,4],9]]]".parse,
                        "[1,1]".parse) == "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
                $addAndReduce("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]".parse,
                        "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]".parse) == "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"
                $addAndReduce("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]".parse,
                        "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]".parse) == "[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]"
                $addAndReduce("[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]".parse,
                        "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]".parse) == "[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]"
                $addAndReduce("[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]".parse,
                        "[7,[5,[[3,8],[1,4]]]]".parse) == "[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]"

        test "Explode":
            check:
                $reduce("[[[[[9,8],1],2],3],4]".parse) == "[[[[0,9],2],3],4]"
                $reduce("[7,[6,[5,[4,[3,2]]]]]".parse) == "[7,[6,[5,[7,0]]]]"
                $reduce("[[6,[5,[4,[3,2]]]],1]".parse) == "[[6,[5,[7,0]]],3]"
                $reduce("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]".parse) == "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"

        test "Split":
            check:
                $reduce(pairNode(10, 11)) == "[[5,5],[5,6]]"
                $reduce(pairNode(20, 21)) == "[[[5,5],[5,5]],[[5,5],[5,6]]]"
                $(pairNode(82, 2) + pairNode(1, 1)) == "[[[[6,0],[7,8]],[[8,9],[9,9]]],[1,1]]"


        test "Lists":
            check:
                $(["[1,1]".parse, "[2,2]".parse, "[3,3]".parse,
                        "[4,4]".parse].foldl(a+b)) == "[[[[1,1],[2,2]],[3,3]],[4,4]]"
                $(["[1,1]".parse, "[2,2]".parse, "[3,3]".parse, "[4,4]".parse,
                        "[5,5]".parse, "[6,6]".parse].foldl(a+b)) == "[[[[5,0],[7,4]],[5,5]],[6,6]]"
                $("""
                [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
                [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
                [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
                [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
                [7,[5,[[3,8],[1,4]]]]
                [[2,[2,2]],[8,[8,1]]]
                [2,9]
                [1,[[[9,3],9],[[9,0],[0,7]]]]
                [[[5,[7,4]],7],1]
                [[[[4,2],2],6],[8,7]]""".dedent.split.map(parse).foldl(a+b)) == "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
