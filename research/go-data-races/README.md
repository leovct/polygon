## Introduction

"Data races are among the most common and hardest to debug types of bugs in concurrent systems. A data race occurs when two goroutines access the same variable concurrently and at least one of the accesses is a write." - https://go.dev/doc/articles/race_detector

Here a list of typical data races (and their PoC):

- Accidently shared variable or unprotected primite/global variable (see `unprotected.go`).
- Race on loop counter (see `loop.go`).
- Unsynchronized send and close operations (see `unsynchronised.go`).

## Sources

- https://go.dev/doc/articles/race_detector
- https://go.dev/ref/mem
