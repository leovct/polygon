#!/bin/bash
MEMLATENCY_BINARY=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/memory-latency/memlatency
POSEIDONHASH_BINARY=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/poseidon-hashes/poseidonhash
PROVER_BINARY=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/proof/prover
WITNESS_URL=http://jhilliard-zero-highmem.hardfork.dev/0x2f0faea6778845b02f9faf84e7e911ef12c287ce7deb924c5925f3626c77906e.json.bz2
MICROBENCH_SCRIPT=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/microbench.sh

function bench {
  name=$1
  instance=$2
  echo "Running benchmark script on $name..."
  gcloud compute ssh --zone "$ZONE" "$instance" --project "$PROJECT" -- \
    "sudo curl -L $MEMLATENCY_BINARY --output /usr/bin/memlatency \
      && sudo chmod +x /usr/bin/memlatency \
      && sudo curl -L $POSEIDONHASH_BINARY --output /usr/bin/poseidonhash \
      && sudo chmod +x /usr/bin/poseidonhash \
      && sudo curl -L $PROVER_BINARY --output /usr/bin/prover \
      && sudo chmod +x /usr/bin/prover \
      && curl -OJL $WITNESS_URL \
      && sudo apt-get install bzip2 --yes \
      && bzip2 -d $(basename $WITNESS_URL) \
      && curl -L $MICROBENCH_SCRIPT | bash" > results/$name.bench 2>&1 &
}

# Load variables.
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi
echo "Values loaded from .env"
echo "PROJECT=$PROJECT"
echo "ZONE=$ZONE"
echo

# Run benchmarks in the background.
rm -rf ./results
mkdir -p results
bench "c3d-standard-8" "leovct-bench-test-01"
bench "t2d-standard-8" "leovct-bench-test-02"

# Wait for all background processes to finish
wait

# Print "Done" after all benchmarks are complete
echo "Done for all benchmarks!"
