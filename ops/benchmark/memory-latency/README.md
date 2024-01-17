# Memory latency tool

```bash
# Build for linux
$ GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o memlatency
# Build for macOS
$ go build -o memlatency

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
