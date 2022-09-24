package main

import (
	"fmt"
	"os"
)

const ALGO_FILE = "input_algo"
const IMAGE_FILE = "input_image"
const ALGO_FILE_TEST = "input_algo_test"
const IMAGE_FILE_TEST = "input_image_test"

const IS_TEST = false

// const IS_TEST = true

func getAlgo() []int {
	algo_file := ALGO_FILE
	if IS_TEST {
		algo_file = ALGO_FILE_TEST
	}
	buf, _ := os.ReadFile(algo_file)
	var algo []int
	for _, b := range buf {
		bb := 0
		if b == 35 {
			bb = 1
		}
		algo = append(algo, bb)
	}

	if len(algo) != 512 {
		panic("wrong len of algo")
	}
	return algo
}

func getImage() [][]int {
	image_file := IMAGE_FILE
	if IS_TEST {
		image_file = IMAGE_FILE_TEST
	}

	buf, _ := os.ReadFile(image_file)
	var image [][]int
	var cur_slice []int

	for _, b := range buf {
		if b == '\n' {
			image = append(image, cur_slice)
			cur_slice = make([]int, 0)
		} else if b == '#' {
			cur_slice = append(cur_slice, 1)
		} else {
			cur_slice = append(cur_slice, 0)
		}
	}

	return image
}

func pad(image [][]int, padLen int) [][]int {
	n := len(image[0])
	nn := padLen + n + padLen

	var nimage [][]int

	for i := 0; i < padLen; i++ {
		nimage = append(nimage, make([]int, nn))
	}

	for _, row := range image {
		var nrow []int

		nrow = append(nrow, make([]int, padLen)...)
		nrow = append(nrow, row...)
		nrow = append(nrow, make([]int, padLen)...)

		nimage = append(nimage, nrow)
	}

	for i := 0; i < padLen; i++ {
		nimage = append(nimage, make([]int, nn))
	}

	return nimage
}

func printImage(image [][]int) {
	for _, row := range image {
		for _, i := range row {
			if i == 0 {
				fmt.Print(".")
			} else {
				fmt.Print("#")

			}
		}
		fmt.Println()
	}
}

func getIndex(image [][]int, i int, j int) int {
	var deltas = [9][2]int{
		{-1, -1}, {-1, 0}, {-1, 1},
		{0, -1}, {0, 0}, {0, 1},
		{1, -1}, {1, 0}, {1, 1},
	}

	var ind = 0
	for _, delta := range deltas {
		ind = ind*2 + image[i+delta[0]][j+delta[1]]
	}

	return ind
}

func convolve(image [][]int, algo []int, si int, sj int) [][]int {
	var nimage [][]int
	for i := 0; i < len(image); i++ {
		nimage = append(nimage, make([]int, len(image[0])))
	}

	for i := si; i < len(image)-si; i++ {
		for j := sj; j < len(image[0])-sj; j++ {
			ind := getIndex(image, i, j)
			nimage[i][j] = algo[ind]
		}
	}

	return nimage
}

func countLit(image [][]int) int {
	count := 0
	for _, row := range image {
		for _, i := range row {
			if i == 1 {
				count += 1
			}
		}
	}
	return count
}

func main() {
	algo := getAlgo()
	image := getImage()

	// part 1
	nimage := pad(image, 55)

	for i := 0; i < 2; i++ {
		nimage = convolve(nimage, algo, 1+i%2, 1+i%2)
	}
	fmt.Println(countLit(nimage))

	// part 2
	nimage = pad(image, 55)

	for i := 0; i < 50; i++ {
		nimage = convolve(nimage, algo, 1+i%2, 1+i%2)
	}
	fmt.Println(countLit(nimage))
}
