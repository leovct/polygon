# Memory latency tool

```bash
$ go build -o memlatency main.go
$ ./memlatency --help
Measure memory latency

Usage:
  memory-latency [flags]

Flags:
  -h, --help          help for memory-latency
  -n, --samples int   Number of samples (default 1000)
  -s, --seed int      Seed for random number generation (default 42)
      --size int      Array size (default 1000)

$ ./memlatency
Seed: 42
Array Size: 1000
Samples: 1000
Average Memory Read Latency: 50ns
Average Memory Write Latency: 40ns
```
