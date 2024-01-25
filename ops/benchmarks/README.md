# Benchmark

Very simple script inspired from [brendangregg](https://github.com/brendangregg)'s [micro benchmark](https://github.com/brendangregg/Misc/blob/master/microbenchmarks/microbench_ubuntu.sh) script to compare cloud instances. The script has been slightly modified to make it work.

## How to use it

Log in to GCP Cloud.

```bash
gcloud auth login
```

Run benchmarks.

```bash
$ ./bench.sh
Running with parameters:
- PROJECT=prj-polygonlabs-devtools-dev
- ZONE=europe-west1-b

Running benchmark script on c3d-standard-8...
Running benchmark script on t2d-standard-8..
Done for all benchmarks!
```

Compare instances.

```bash
diff -wy --color results/c3d-standard-8.bench results/t2d-standard-8.bench
```
