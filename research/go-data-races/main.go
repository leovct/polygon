package main

func main() {
	// Run the program using `$ go run .`.
	// Everything looks right? Are you sure?
	// Uncomment one of the commented functions and try running it with the `--race` flag.
	// `$ go run --race .`

	//UnprotectedVariable()
	UnprotectedVariableFixed()

	//UnprotectedVariables()
	UnprotectedVariablesFixed()

	//RaceLoop()
	RaceLoopFixed()

	//UnsynchronisedChannel()
	UnsynchronisedChannelFixed()
}
