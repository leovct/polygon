#!/bin/bash
MEMLATENCY_BINARY_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/memory-latency/memlatency
POSEIDONHASH_BINARY_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/poseidon-hashes/poseidonhash
PROVER_BINARY_ARCHIVE_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/proof/prover.tar.bz2
WITNESS_ARCHIVE_URL=http://jhilliard-zero-highmem.hardfork.dev/0x2f0faea6778845b02f9faf84e7e911ef12c287ce7deb924c5925f3626c77906e.json.bz2
MICROBENCH_SCRIPT_URL=https://raw.githubusercontent.com/leovct/polygon/feat/benchmarks/ops/benchmark/microbench.sh

function bench {
  name=$1
  instance=$2
  echo "Running benchmark script on $name..."
  gcloud compute ssh --zone "$ZONE" "$instance" --project "$PROJECT" -- \
    "sudo curl -L $MEMLATENCY_BINARY_URL --output /usr/bin/memlatency \
      && sudo chmod +x /usr/bin/memlatency \
      && sudo curl -L $POSEIDONHASH_BINARY_URL --output /usr/bin/poseidonhash \
      && sudo chmod +x /usr/bin/poseidonhash \
      && sudo apt-get install bzip2 --yes \
      && sudo curl -OJL $PROVER_BINARY_ARCHIVE_URL \
      && bzip2 -d $(basename $PROVER_BINARY_ARCHIVE_URL) \
      && sudo chmod +x /usr/bin/prover \
      && sudo mv prover /usr/bin/prover \
      && curl -OJL $WITNESS_ARCHIVE_URL \
      && bzip2 -d $(basename $WITNESS_ARCHIVE_URL) \
      && curl -L $MICROBENCH_SCRIPT_URL | bash" > results/$name.bench 2>&1 &
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
bench "t2d-standard-16" "leovct-bench-test-03"

# Wait for all background processes to finish
wait

# Print "Done" after all benchmarks are complete
echo "Done for all benchmarks!"
