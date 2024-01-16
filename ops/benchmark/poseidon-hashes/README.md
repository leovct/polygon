# Poseidon Hashes

```bash
$ rustc --version
rustc 1.77.0-nightly (714b29a17 2024-01-15)
$ cargo build
...
$ cp ./target/debug/poseidon-hashes poseidonhash

$ ./target/debug/poseidon-hashes --help
Usage: ./target/debug/poseidon-hashes <num_iterations> <num_threads>

$ ./target/debug/poseidon-hashes 100 2
Thread 0 finished in 0.011327166 seconds
Thread 1 finished in 0.01140525 seconds
Total time: 0.011629875 seconds
Average time per hash: 0.00011629875 seconds
```
