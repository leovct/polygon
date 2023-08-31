# 🤖 Zero Prover VM Setup

## Table of contents

- [Introduction](#introduction)
- [Setup](#setup)

## Introduction

Quick setup to run the zero-prover setup with a leader and a worker, a mock of an edge REST endpoint and a handy server to save proofs to disk.

The idea is to be able to run the setup and to integrate it into a CI job later.

Most of the code is located in this [repository](https://github.com/mir-protocol/zero-provers).

## Setup

1. Start an Ubuntu 22.04 VM (x86). Make sure to have at least 32GB of memory (even more is better!) and 100GB of storage. For example, you can use `c5.4xlarge` on AWS.

2. Connect to the VM

3. Install dependencies

```sh
$ echo "Set up to run the zero prover setup" \
  && echo "Install packages" \
  && sudo apt-get update \
  && sudo apt-get install -y build-essential pkg-config libssl-dev protobuf-compiler \
  && echo "Install rust" \
  && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh \
  && source "$HOME/.cargo/env" \
  && cargo version \
  && echo "install nighlty-2023-04-17" \
  && rustup install nightly-2023-04-17 \
  && rustup default nightly-2023-04-17 \
  && rustup component add rust-src --toolchain nightly-2023-04-17 \
  && echo "Install go" \
  && sudo snap install go --classic \
  && go version \
  && echo "Install grpcurl" \
  && wget https://github.com/fullstorydev/grpcurl/releases/download/v1.7.0/grpcurl_1.7.0_linux_x86_64.tar.gz \
  && tar -xvf grpcurl_1.7.0_linux_x86_64.tar.gz \
  && chmod +x grpcurl \
  && sudo mv grpcurl /usr/local/bin \
  && grpcurl -version
```

4. Generate an SSH key to clone the [zero-provers](https://github.com/mir-protocol/zero-provers) private repository. Don't forget to add it to your Github account.

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" && cat ~/.ssh/id_ed25519.pub
```

5. Build the binaries

🚨 Note: You may need to switch to a custom branch!

```sh
$ echo "Clone the zero-provers repository" \
  && git clone git@github.com:mir-protocol/zero-provers.git \
  && cd zero-provers \
  && echo "Build binaries" \
  && cargo build --bin zero_prover_leader --release -F extern-query-mock \
  && cargo build --bin zero_prover_worker --release \
  && sudo mv ./target/release/zero_prover_leader /usr/local/bin \
  && sudo mv ./target/release/zero_prover_worker /usr/local/bin \
  && cd .. \
  && echo "Create the prover secret key" \
  && touch prover.key \
  && echo \"3a8f45d67197b22e6d334ce7086a14b50c6d42b2da4b2f8a8115167d5ed5b693\" > prover.key \
  && echo "Clone the mock server repository" \
  && cd \
  && git clone git@github.com:leovct/edge-grpc-mock-server.git \
  && cd edge-grpc-mock-server \
  && git checkout missing_prev_block_bypass_hack \
  && go build -o edge-grpc-mock-server main.go \
  && sudo mv ./edge-grpc-mock-server /usr/local/bin
```

6. Start the mock server

```sh
edge-grpc-mock-server \
  --grpc-port 8546 \
  --http-port 8080 \
  --http-save-endpoint /save \
  --mock-data-block-dir edge-grpc-mock-server/data/blocks \
  --mock-data-trace-dir edge-grpc-mock-server/data/traces \
  --mode dynamic \
  --update-data-threshold 30 \
  --output-dir out \
  --verbosity 0
```

7. Start the worker

```sh
RUST_LOG="debug" zero_prover_worker http://127.0.0.1:9001 \
  --leader-notif-min-delay 1sec \
  -i 127.0.0.1 \
  -p 9002 \
  -a http://127.0.0.1:9002
```

8. Start the leader

```sh
RUST_LOG="debug" zero_prover_leader \
  --secret-key-path prover.key \
  --contract-address 0x0000000000000000000000000000000000000000 \
  --rpc-url http://change_me.com \
  --full-node-endpoint http://127.0.0.1:8546 \
  --proof-complete-endpoint http://127.0.0.1:8080/save \
  --commit-height-delta-before-generating-proofs 0 \
  -i 127.0.0.1 \
  -p 9001
```
