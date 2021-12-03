import std/strutils
import std/sequtils
import std/sugar

type
    Direction = enum
        forward, up, down
    
    Instruction = object
        direction: Direction
        value: int

proc parseInput(): seq[Instruction] =
    let f = open("input")
    defer: f.close()

    for line in f.lines:
        let direction = case line.split(' ')[0]:
            of "forward":
                forward
            of "down":
                down
            of "up":
                up
            else:
                raise newException(FieldError, "bad input")
        
        let value = parseInt(line.split[1])

        result.add(Instruction(direction: direction, value: value))
    


proc part1(instructions: seq[Instruction]): int = 
    var pos, depth = 0
    for insturction in instructions:
        case insturction.direction:
            of forward:
                pos += insturction.value
            of down:
                depth += insturction.value
            of up:
                depth -= insturction.value
    
    result = pos*depth

proc part2(instructions: seq[Instruction]): int = 
    var pos, depth, aim = 0
    for insturction in instructions:
        case insturction.direction:
            of forward:
                pos += insturction.value
                depth += (insturction.value * aim)
            of down:
                aim += insturction.value
            of up:
                aim -= insturction.value
    
    result = pos*depth
    

when isMainModule:
  var instructions = parseInput()
  echo part1(instructions)
  echo part2(instructions)
  