package main

import (
	"fmt"
	"sync"
)

// Concurrent reads and writes to a variable leads to races.
// Note: this also works with global variables and struct types.
func UnprotectedVariable() {
	var myVar int

	go func() {
		myVar = 1
	}()

	go func() {
		fmt.Println(myVar)
	}()
}

// To fix the data races when performing concurrent reads and writes to a global variable, use
// mutex or a channel to make sure only one of the goroutine is modifying the memory at a time.
func UnprotectedVariableFixed() {
	var myVar int
	var myVarMutex sync.RWMutex

	go func() {
		myVarMutex.Lock()
		defer myVarMutex.Unlock()
		myVar = 1
	}()

	go func() {
		myVarMutex.RLock()
		defer myVarMutex.RUnlock()
		fmt.Println(myVar)
	}()
}

func UnprotectedVariables() {
	var a, b int

	go func() {
		a = 1
		b = 2
	}()

	go func() {
		print(b)
		print(a)
	}()
}

func UnprotectedVariablesFixed() {
	type data struct {
		value int
		mutex sync.RWMutex
	}

	var a, b data

	go func() {
		a.mutex.Lock()
		defer a.mutex.Unlock()
		a.value = 1

		b.mutex.Lock()
		defer b.mutex.Unlock()
		b.value = 2
	}()

	go func() {
		b.mutex.RLock()
		defer b.mutex.RUnlock()
		print(b.value)

		a.mutex.RLock()
		defer a.mutex.RUnlock()
		print(a.value)
	}()
}
