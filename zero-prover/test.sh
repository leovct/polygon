#!/bin/sh

# Kill processes
killall zero_prover_worker
killall zero_prover_leader
killall mock-server
rm -rf zero-provers

# Get components
git clone https://github.com/mir-protocol/zero-provers
git clone https://github.com/leovct/edge-grpc-mock-server

# Build binaries
cd zero-provers
cargo build --bin zero_prover_leader --release -F extern-query-mock
cargo build --bin zero_prover_worker --release
rm -rf /usr/local/bin/zero_prover_worker && mv target/release/zero_prover_worker /usr/local/bin/
rm -rf /usr/local/bin/zero_prover_leader && mv target/release/zero_prover_leader /usr/local/bin/

cd .. && cd edge-grpc-mock-server
go build -o mock-server main.go
rm -rf /usr/local/bin/mock-server && mv mock-server /usr/local/bin

# Create key
cd
rm prover.key
touch prover.key && echo \"3a8f45d67197b22e6d334ce7086a14b50c6d42b2da4b2f8a8115167d5ed5b693\" > prover.key

# Run mock-server
cd
rm -rf *.log
mock-server \
  --debug \
  --grpc-port 8546 \
  --http-port 8080 \
  --http-save-endpoint /save \
  --mock-data-dir edge-grpc-mock-server/data \
  --output-dir out > ../mock_server.log 2>&1 &

# Start worker
cd
sleep 5
RUST_LOG="debug" zero_prover_worker \
  --leader-notif-min-delay 1sec \
  -a http://127.0.0.1:9002 \
  -i 127.0.0.1 \
  -p 9002 \
  http://127.0.0.1:9002 > work.log 2>&1 &

# Start leader
sleep 40
RUST_LOG="debug" zero_prover_leader \
  --secret-key-path prover.key \
  --contract-address 0x0000000000000000000000000000000000000000 \
  --rpc-url http://change_me.com \
  --full-node-endpoint http://127.0.0.1:8546 \
  --proof-complete-endpoint http://127.0.0.1:8080/save \
  --commit-height-delta-before-generating-proofs 0 \
  -i 127.0.0.1 -p 9001 > leader.log 2>&1 &