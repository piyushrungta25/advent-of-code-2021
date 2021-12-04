import std/sequtils
import std/strutils
import std/re
import std/sugar
import std/math
import std/sets

const N = 5
type
    Board = seq[seq[int]]
    Inputs = seq[int]
    Game = object
        boards: seq[Board]
        inputs: Inputs


proc parseInput(): Game =
    let f = open("./input")
    defer: f.close

    let inputs = f.readLine.split(",").map(parseInt)
    discard f.readline() # empty line

    let boards: seq[Board] = collect:
        for s in f.readAll.strip.split("\n\n"):
            s.strip.split(re"\s+").map(parseInt).distribute(N)

    return Game(boards: boards, inputs: inputs)


proc sumOfUnmarked(board: Board): int =
    return board.mapIt(it.filterIt(it != -1).sum).sum


proc bingo(board: Board): bool =
    for row in board:
        if row.sum == -5: return true

    for i in 0..4:
        if board.mapIt(it[i]).sum == -5: return true


proc markIfPresent(board: var Board, num: int): bool =
    for i, row in board:
        for j, n in row:
            if n == num:
                board[i][j] = -1

    return board.bingo


proc scores(game: var Game): seq[int] =
    var not_bingo = toHashSet toSeq(0..<game.boards.len)

    for num in game.inputs:
        for i in not_bingo.toSeq.toSeq:
            if game.boards[i].markIfPresent(num):
                not_bingo.excl i
                result.add(num*game.boards[i].sumOfUnmarked)


when isMainModule:
    var game = parseInput()
    var all_scores = game.scores
    echo "part1: ", all_scores[0]
    echo "part2: ", all_scores[^1]
