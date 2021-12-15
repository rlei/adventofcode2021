package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
	"strings"
)

type Octopi struct {
	grid [][]int
	rows int
	cols int
}

func main() {
	sync := flag.Bool("sync", false, "Search for the first sync step, instead of counting flashes for the first 100 steps")

	flag.Parse()

	var grid [][]int
	reader := bufio.NewReader(os.Stdin)
	for line, err := reader.ReadString('\n'); err != io.EOF; line, err = reader.ReadString('\n') {
		l := strings.TrimSpace(line)
		row := make([]int, len(l))
		for i, ch := range l {
			row[i] = int(ch) - int('0')
		}
		grid = append(grid, row)
	}

	octopi := Octopi{grid: grid, rows: len(grid), cols: len(grid[0])}
	if *sync {
		step := 0
		for {
			flashes := octopi.step()
			step++
			if flashes == octopi.rows*octopi.cols {
				// synchronized
				fmt.Printf("Synchronizing after step %d\n", step)
				break
			}
		}
	} else {
		totalFlashes := 0
		for i := 0; i < 100; i++ {
			totalFlashes += octopi.step()
		}

		fmt.Printf("Total flashes after 100 steps: %d\n", totalFlashes)
	}
}

func (o *Octopi) step() int {
	for y, row := range o.grid {
		for x := range row {
			o.gainEnergy(y, x)
		}
	}

	flashes := 0
	for y, row := range o.grid {
		for x := range row {
			if o.grid[y][x] > 9 {
				o.grid[y][x] = 0
				flashes++
			}
		}
	}
	return flashes
}

func (o *Octopi) gainEnergy(y, x int) {
	if y < 0 || y >= o.rows || x < 0 || x >= o.cols || o.grid[y][x] > 9 {
		return
	}
	o.grid[y][x]++
	if o.grid[y][x] > 9 {
		o.gainEnergy(y-1, x-1)
		o.gainEnergy(y-1, x)
		o.gainEnergy(y-1, x+1)
		o.gainEnergy(y, x-1)
		o.gainEnergy(y, x+1)
		o.gainEnergy(y+1, x-1)
		o.gainEnergy(y+1, x)
		o.gainEnergy(y+1, x+1)
	}

}
