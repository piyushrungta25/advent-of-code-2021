import std/[tables, algorithm, math]

const mappings = {'(': ')', '[': ']', '{': '}', '<': '>'}.toTable
const illegalScoresMap = {')': 3, ']': 57, '}': 1197, '>': 25137}.toTable
const completionScoresMap = {'(': 1, '[': 2, '{': 3, '<': 4}.toTable

var illegalScores: seq[int]
var completionScores: seq[int]

for line in "input".lines:
    block outer:
        var stack: seq[char]
        for c in line:
            if mappings.contains(c): # is opening bracket
                stack.add(c)
            else: # is closing
                if mappings[stack.pop] != c: # the closing does not match opening
                    illegalScores.add illegalScoresMap[c]
                    break outer

        # this is not a illegal string, calculate the completion score
        var completionScore: int
        while stack.len != 0:
            completionScore = completionScore*5 + completionScoresMap[stack.pop]

        # the check for completionScore > 0 is not really required since every
        # line is either illegal or incomplete
        if completionScore > 0:
            completionScores.add(completionScore)

echo illegalScores.sum
echo completionScores.sorted[int(completionScores.len/2)]
