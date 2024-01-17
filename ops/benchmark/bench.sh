#!/bin/bash
PROJECT=prj-polygonlabs-devtools-dev
ZONE=europe-west1-b

MEMLATENCY_BINARY_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/memory-latency/memlatency
POSEIDONHASH_BINARY_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/poseidon-hashes/poseidonhash
LEADER_BINARY_ARCHIVE_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/proof/prover.tar.gz
WITNESS_ARCHIVE_URL=http://jhilliard-zero-highmem.hardfork.dev/0x2f0faea6778845b02f9faf84e7e911ef12c287ce7deb924c5925f3626c77906e.json.bz2
MICROBENCH_SCRIPT_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/microbench.sh

function download_binaries {
  name=$1
  instance=$2

}

function run_benchmark {
  name=$1
  instance=$2

  echo "Downloading binaries..."
  gcloud compute ssh --zone "$ZONE" "$instance" --project "$PROJECT" -- \
    "echo Download memlatency \
      && curl -OJL $MEMLATENCY_BINARY_URL \
      && chmod +x memlatency \
      && sudo mv memlatency /usr/bin/memlatency \
      && echo Download poseidonhash \
      && curl -OJL $POSEIDONHASH_BINARY_URL \
      && chmod +x poseidonhash \
      && sudo mv poseidonhash /usr/bin/poseidonhash \
      && echo Download leader \
      && curl -OJL $LEADER_BINARY_ARCHIVE_URL \
      && tar -xzf $(basename $LEADER_BINARY_ARCHIVE_URL) \
      && chmod +x leader \
      && sudo mv leader /usr/bin/leader \
      && echo Download witness file \
      && sudo apt-get install bzip2 --yes \
      && curl -OJL $WITNESS_ARCHIVE_URL \
      && bzip2 --decompress $(basename $WITNESS_ARCHIVE_URL) --force"

  echo; echo "Running benchmark script on $name..."
  gcloud compute ssh --zone "$ZONE" "$instance" --project "$PROJECT" -- \
    "curl -L $MICROBENCH_SCRIPT_URL | bash" > results/$name.bench 2>&1 &
}

echo "Running with parameters:"
echo "- PROJECT=$PROJECT"
echo "- ZONE=$ZONE"
echo

# Run benchmarks in the background.
rm -rf ./results
mkdir -p results
run_benchmark "t2d-standard-16" "leovct-bench-test-05"

# Wait for all background processes to finish
wait

# Print "Done" after all benchmarks are complete
echo "Done for all benchmarks!"
