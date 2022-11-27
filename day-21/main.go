package main

import "fmt"

func getRoll(die int) int {
	return (die % 100) + 1
}

type ind struct {
	r    int
	ts   int
	pos  int
	epos int
}

var dp map[ind]int = make(map[ind]int)

func getPossible() map[int]int {
	ret := make(map[int]int)

	ret[3] = 1
	ret[4] = 3
	ret[5] = 6
	ret[6] = 7
	ret[7] = 6
	ret[8] = 3
	ret[9] = 1

	return ret
}

func rec(i ind) int {
	val, present := dp[i]
	if present {
		return val
	}

	if i.r == 0 && i.ts != 0 {
		dp[i] = 0
		return 0
	} else if i.r == 0 && i.ts == 0 {
		dp[i] = 1
		return 1
	} else if i.r != 0 && i.ts == 0 {
		dp[i] = 0
		return 0
	} else if i.ts < 0 {
		dp[i] = 0
		return 0
	}

	ways := 0

	possible_scores := getPossible()
	for sc, v := range possible_scores {
		new_pos := (i.pos + sc) % 10
		new_score := new_pos + 1
		if new_score <= i.ts {
			// fmt.Println("score ", new_score, "pos ", new_pos, "sc ", sc, "v", v)

			ways += (v * rec(ind{i.r - 1, i.ts - new_score, new_pos}))
		}
	}

	// fmt.Println("setting ", i, "to ", ways)
	dp[i] = ways
	return ways
}

func part2() {
	p1_pos := 3
	p2_pos := 7

	p1_univ := 0
	for r := 21; r > 0; r-- {
		p1_wins := 0
		for s := 21; s <= 31; s++ {
			p1_wins += rec(ind{r, s, p1_pos})
		}
		p2_loses := 0
		for s2 := 0; s2 < 21; s2++ {
			p2_loses += rec(ind{r - 1, s2, p2_pos})
		}

		p1_univ += (p1_wins * p2_loses)
	}

	fmt.Println(p1_univ)

}

func part1() {
	p1_pos := 5
	p2_pos := 0

	roll_count := 0
	p1_score := 0
	p2_score := 0

	die := 0

	for p1_score < 1000 && p2_score < 1000 {

		if roll_count%2 == 0 { // player 1
			die = getRoll(die)
			p1_pos += die
			die = getRoll(die)
			p1_pos += die
			die = getRoll(die)
			p1_pos += die
			p1_pos = (p1_pos % 10)
			p1_score += p1_pos + 1
		} else { // player 2
			die = getRoll(die)
			p2_pos += die
			die = getRoll(die)
			p2_pos += die
			die = getRoll(die)
			p2_pos += die
			p2_pos = (p2_pos % 10)
			p2_score += p2_pos + 1
		}
		roll_count += 3

	}

	fmt.Println(p1_pos, p1_score, p2_pos, p2_score, roll_count)
	if p1_score >= 1000 {
		fmt.Println(roll_count * p2_score)
	} else {
		fmt.Println(roll_count * p1_score)
	}
}

func main() {
	// part1()
	part2()
	fmt.Println(len(dp))

	// for r := 21; r > 0; r-- {
	// 	for s := 21; s <= 30; s++ {
	// 		fmt.Println(r, s, rec(ind{r, s, 3}))
	// 	}
	// }

	// dic := make(map[int]int)

	// for i := 1; i < 4; i++ {
	// 	for j := 1; j < 4; j++ {
	// 		for k := 1; k < 4; k++ {
	// 			dic[i+j+k] += 1
	// 		}
	// 	}
	// }

	// fmt.Println(dic)

	// fmt.Println(rec(ind{2, 6, 1}))
}
