package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Coord struct {
	x, y, z int
}

type Instruction struct {
	action int
	from   Coord
	to     Coord
}

// off x=-18136..-10686,y=33123..48632,z=51138..74719
func parse(s string) (int, int) {
	xs := strings.Split(s, "=")
	xs = strings.Split(xs[1], "..")
	xStart, _ := strconv.Atoi(xs[0])
	xEnd, _ := strconv.Atoi(xs[1])
	return xStart, xEnd
}

func getInput() []Instruction {
	f, _ := os.ReadFile("input")
	instructions := make([]Instruction, 0)
	for _, line := range strings.Split(string(f), "\n") {
		fs := strings.Split(line, " ")
		command := fs[0]
		action := 0
		if command == "on" {
			action = 1
		}

		coords := strings.Split(fs[1], ",")
		xStart, xEnd := parse(coords[0])
		yStart, yEnd := parse(coords[1])
		zStart, zEnd := parse(coords[2])

		instruction := Instruction{
			action,
			Coord{xStart, yStart, zStart},
			Coord{xEnd, yEnd, zEnd},
		}

		instructions = append(instructions, instruction)
	}

	return instructions
}

func clip(xs, xe int) (bool, int, int) {
	if xs < -50 && xe < -50 {
		return false, 0, 0
	}
	if xs > 50 && xe > 50 {
		return false, 0, 0
	}
	if xs < -50 {
		xs = -50
	} else if xs > 50 {
		xs = 50
	}

	if xe < -50 {
		xe = -50
	} else if xe > 50 {
		xe = 50
	}

	if xs < xe {
		return true, xs, xe
	}

	return true, xe, xs

}

func main() {
	var cube [101][101][101]int

	for _, instruction := range getInput() {
		xValid, xStart, xEnd := clip(instruction.from.x, instruction.to.x)
		yValid, yStart, yEnd := clip(instruction.from.y, instruction.to.y)
		zValid, zStart, zEnd := clip(instruction.from.z, instruction.to.z)

		if xValid && yValid && zValid {
			for x := xStart; x <= xEnd; x++ {
				for y := yStart; y <= yEnd; y++ {
					for z := zStart; z <= zEnd; z++ {
						cube[x+50][y+50][z+50] = instruction.action
					}
				}
			}

		}
	}

	count := 0
	for x := 0; x < 101; x++ {
		for y := 0; y < 101; y++ {
			for z := 0; z < 101; z++ {
				count += cube[x][y][z]
			}
		}
	}

	fmt.Println(count)

}
