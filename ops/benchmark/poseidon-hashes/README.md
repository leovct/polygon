# Poseidon Hashes

```bash
$ rustc --version
rustc 1.77.0-nightly (714b29a17 2024-01-15)
# Compile a Rust program for linux from macOS M1: https://saktidwicahyono.name/blogs/cross-compile-to-linux-amd64-from-mac-m1
$ CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-unknown-linux-gnu-gcc cargo build --target=x86_64-unknown-linux-gnu
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
