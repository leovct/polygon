package main

import (
	"fmt"
	"math/rand"
	"os"
	"time"

	"github.com/spf13/cobra"
)

var (
	seed          int64
	samples, size int
	array         []int
	r             *rand.Rand
)

var rootCmd = &cobra.Command{
	Use:   "memory-latency",
	Short: "Measure memory latency",
	Run:   measureMemoryLatency,
}

func init() {
	rootCmd.PersistentFlags().Int64VarP(&seed, "seed", "s", 42, "Seed for random number generation")
	r = rand.New(rand.NewSource(99))
	rootCmd.PersistentFlags().IntVarP(&size, "size", "", 1000, "Array size")
	rootCmd.PersistentFlags().IntVarP(&samples, "samples", "n", 1000, "Number of samples")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func measureMemoryLatency(cmd *cobra.Command, args []string) {
	fmt.Printf("Seed: %d\n", seed)
	fmt.Printf("Array Size: %d\n", size)
	fmt.Printf("Samples: %d\n", samples)

	// Create the array
	for i := 0; i < size; i++ {
		array = append(array, i)
	}

	// Warm-up phase.
	for i := 0; i < 1000; i++ {
		randomRead()
	}

	// Benchmarks.
	averageReadLatency := computeAverageTimeExecution(randomRead, samples)
	fmt.Printf("Average Memory Read Latency: %s\n", averageReadLatency)

	averageWriteLatency := computeAverageTimeExecution(randomWrite, samples)
	fmt.Printf("Average Memory Write Latency: %s\n", averageWriteLatency)
}

// randomRead performs a random read operation on an array.
func randomRead() {
	index := r.Intn(size)
	_ = array[index]
}

// randomWrite performs a random write operation on an array.
func randomWrite() {
	index := r.Intn(size)
	array[index] = 10
}

// computeAverageTimeExecution measures the average time it takes for a given function to execute.
func computeAverageTimeExecution(fn func(), samples int) time.Duration {
	sum := time.Duration(0)
	for i := 0; i < samples; i++ {
		startTime := time.Now()
		fn()
		sum += time.Since(startTime)
	}
	return sum / time.Duration(samples)
}
