# 🤖 Zero Prover VM Setup

## Table of contents

- [Introduction](#introduction)
- [Setup](#setup)
- [Debug](#debug)

## Introduction

Quick setup to run the zero-prover setup with a leader and a worker, a mock of an edge REST endpoint and a handy server to save proofs to disk.

The idea is to be able to run the setup and to integrate it into a CI job later.

Most of the code is located in this [repository](https://github.com/mir-protocol/zero-provers).

## Setup

1. Start an Ubuntu 22.04 VM. Make sure to have at least 32GB of memory (even more is better!) and 100GB of storage.

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
  && echo "Install dumb-init" \
  && sudo wget -O /dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 \
  && sudo chmod +x /dumb-init \
  && sudo mv /dumb-init /usr/local/bin \
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

🚨 Note: This step will remove the hardcoded edge devnet address and use the local mock endpoint instead!

```sh
$ echo "Clone the repository" \
  && git clone git@github.com:mir-protocol/zero-provers.git \
  && cd zero-provers \
  && git checkout trace_parsing_in_prog_fixes \
  && echo "Remove the hardcoded edge devnet address" \
  && sed -i 's|http://34.111.47.249:10000|http://127.0.0.1:8546|g' leader/src/external_query/mocks/contract_mock.rs \
  && echo "Build binaries" \
  && RUSTFLAGS=-Ctarget-cpu=native cargo build --bin zero_prover_leader --release -F extern-query-mock \
  && RUSTFLAGS=-Ctarget-cpu=native cargo build --bin zero_prover_worker --release \
  && sudo mv ./target/release/zero_prover_leader /usr/local/bin \
  && sudo mv ./target/release/zero_prover_worker /usr/local/bin \
  && echo "Create the prover secret key" \
  && touch prover.key \
  && echo \"3a8f45d67197b22e6d334ce7086a14b50c6d42b2da4b2f8a8115167d5ed5b693\" > prover.key
```

6. Start the leader

```sh
$ RUST_LOG="debug" dumb-init -- zero_prover_leader \
    --secret-key-path prover.key \
    --contract-address 0x0000000000000000000000000000000000000000 \
    --rpc-url http://change_me.com \
    --full-node-endpoint http://127.0.0.1:8546 \
    --proof-complete-endpoint http://127.0.0.1:8080/save \
    --commit-height-delta-before-generating-proofs 0 \
    -i 127.0.0.1 \
    -p 9001
```

7. Start the worker

```sh
RUST_LOG="debug" dumb-init -- zero_prover_worker http://127.0.0.1:9001 \
    --leader-notif-min-delay 1sec \
    -i 127.0.0.1 \
    -p 9002 \
    -a http://127.0.0.1:9002
```

8. Start the edge mock REST endpoint

Note: This will also start the "save" endpoint which saves proofs to disk.

```sh
$ cd \
  && git clone git@github.com:mir-protocol/zero-provers.git zero-provers-tmp \
  && cd zero-provers-tmp \
  && git checkout leovct/feat-integration-test-workflow \
  && cd .github/workflows/server \
  && go run main.go
```

## Debug

1. Make sure to use the correct nightly build

🚨 Note: This will need a full rebuild of the binaries (and don't forget to move them to `/usr/local/bin`)!

```sh
rustup install nightly-2023-03-07 && rustup default nightly-2023-03-07
```

2. Make sure there is no override in `leader/src/external_query/mocks/contract_mock.rs`

```sh
sed -i 's|http://127.0.0.1:8546|http://34.111.47.249:10000|g' leader/src/external_query/mocks/contract_mock.rs
```

3. Start the leader without `dumb-init` and using the edge devnet endpoint

```sh
RUST_LOG="info" zero_prover_leader \
  --secret-key-path prover.key \
  --contract-address 0x0000000000000000000000000000000000000000 \
  --rpc-url http://change_me.com \
  --full-node-endpoint http://34.111.47.249:10000 \
  --proof-complete-endpoint http://127.0.0.1:8080/save \
  --commit-height-delta-before-generating-proofs 0 \
  -i 127.0.0.1 \
  -p 9001
```

4. Start the worker without `dumb-init`

```sh
RUST_LOG="info" zero_prover_worker http://127.0.0.1:9001 \
  --leader-notif-min-delay 1sec \
  -i 127.0.0.1 \
  -p 9002 \
  -a http://127.0.0.1:9002
```
