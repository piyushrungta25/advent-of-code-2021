import std/sequtils
import std/strutils
import std/re
import std/sugar
import std/math

type
    Board = array[5, array[5, int]]
    Inputs = seq[int]
    Game = object
        boards: seq[Board]
        inputs: Inputs

proc toBoard(ints: seq[int]): Board =
    for i, row in result:
        for j, num in row:
            result[i][j] = ints[i*5+j]

proc sumOfUnmarked(board: Board): int =
    for row in board:
        for num in row:
            if num >= 0:
                result += num

proc markIfPresent(board: var Board, num: int) =
    for i, row in board:
        for j, n in row:
            if n == num:
                board[i][j] = -1

proc bingo(board: Board): bool =
    for row in board:
        if row.sum == -5:
            return true

    for i in 0..4:
        var sum: int
        for row in board:
            sum += row[i]
        if sum == -5:
            return true

    return false


proc parseInput(): Game =
    let f = open("./input")
    defer: f.close

    let inputs = f.readLine.split(",").mapIt(parseInt(it))
    discard f.readline() # empty line

    let boards: seq[Board] = collect:
        for s in f.readAll.strip.split("\n\n"):
            collect(for i in s.strip.split(re"\s+"): parseInt(i)).toBoard

    return Game(boards: boards, inputs: inputs)

proc part1(): int =
    var game = parseInput()
    for i in game.inputs:
        for board in game.boards.mitems:
            board.markIfPresent(i)
            if board.bingo:
                return i*board.sumOfUnmarked


proc part2(): int =
    var game = parseInput()

    var boards = game.boards

    for i, num in game.inputs:
        for board in boards.mitems: board.markIfPresent(num)

        boards = boards.filterIt(not it.bingo)
        if boards.len == 1:
            var mi = i
            while not boards[0].bingo:
                mi += 1
                boards[0].markIfPresent(game.inputs[mi])

            return boards[0].sumOfUnmarked * game.inputs[mi]


when isMainModule:
    echo part1() == 29440
    echo part2() == 13884
