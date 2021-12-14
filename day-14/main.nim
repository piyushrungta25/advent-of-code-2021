include ../imports

type
    Counts = CountTable[char]
    Cache = ref Table[(char, char, int), Counts]
    Rules = Table[string, string]

proc parse(filename: string): (string, Rules) =
    let parts = filename.readFile.split("\n\n")
    result[0] = parts[0].strip

    for rule in parts[1].splitLines:
        let (_, frm, to) = rule.scanTuple("$w -> $w")
        result[1][frm] = to


proc rec(c1, c2: char, rules: Rules, depth, maxDepth: int,
        cache: Cache): Counts =
    if depth > maxDepth:
        return

    let remainingDepth = maxDepth - depth + 1
    if not cache.contains((c1, c2, remainingDepth)):
        var cur_count: CountTable[char]
        if c1&c2 in rules:
            let ch = rules[c1&c2][0]
            cur_count.inc(ch)
            cur_count.merge(rec(c1, ch, rules, depth+1, maxDepth, cache))
            cur_count.merge(rec(ch, c2, rules, depth+1, maxDepth, cache))

        cache[(c1, c2, remainingDepth)] = cur_count
    return cache[(c1, c2, remainingDepth)]


proc diff(str: string, rules: Rules, cache: Cache, maxDepth: int): int =
    var total_counts = str.toCountTable

    for i in 0..<(str.len-1):
        total_counts.merge(rec(str[i], str[i+1], rules, 1, maxDepth, cache))

    return total_counts.largest[1] - total_counts.smallest[1]


when isMainModule:
    let (str, rules) = parse("input")
    var cache = Cache()
    echo "part1: ", diff(str, rules, cache, 10)
    echo "part2: ", diff(str, rules, cache, 40)
