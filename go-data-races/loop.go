package main

import (
	"fmt"
	"sync"
)

// The variable i in the function literal is the same variable used by the loop, so the read in the
// goroutine races with the loop increment. This program typically prints 55555 instead of 01234.
func RaceLoop() {
	var wg sync.WaitGroup
	wg.Add(5)
	for i := 0; i < 5; i++ {
		go func() {
			fmt.Println(i)
			wg.Done()
		}()
	}
	wg.Wait()
}

// Fix the race loop data race issue by making a copy of the variable to increment and read.
func RaceLoopFixed() {
	var wg sync.WaitGroup
	wg.Add(5)
	for i := 0; i < 5; i++ {
		go func(j int) {
			fmt.Println(j)
			wg.Done()
		}(i)
	}
	wg.Wait()
}
