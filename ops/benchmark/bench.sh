#!/bin/bash

function bench {
  name=$1
  instance=$2
  echo "Running benchmark script on $name..."
  gcloud compute ssh --zone "$ZONE" "$instance" --project "$PROJECT" -- \
    "curl -L https://gist.github.com/leovct/833bc3dc065df839cfeb24c10cbcb57a/raw/microbench.sh | bash" > results/$name.bench 2>&1 &
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
mkdir -p results
bench "c3d-standard-8" "leovct-bench-test-01"
bench "t2d-standard-8" "leovct-bench-test-02"

# Wait for all background processes to finish
wait

# Print "Done" after all benchmarks are complete
echo "Done for all benchmarks!"
