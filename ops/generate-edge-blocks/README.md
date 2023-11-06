## 🧱 Generate Edge blocks

## Table of contents

- [Introduction](#introduction)
- [Usage](#usage)

## Introduction

We would like to be able to generate a list of blocks that represent the activity of the Polygon chain. These mock blocks would then be used to check that the zero-prover can generate proofs for all these types of transactions (native, erc20 and erc721 transfers, contract deployments of different sizes, contract interactions, storage writes of any types, call most of the opcodes of the EVM, etc.).

## Usage

First, run a local blockchain (for example using `geth`).

```sh
geth \
  --dev \
  --dev.period 5 \
  --http \
  --http.addr localhost \
  --http.port 8545 \
  --http.api 'admin,debug,web3,eth,txpool,personal,clique,miner,net' \
  --verbosity 5 \
  --rpc.gascap 100000000000 \
  --rpc.txfeecap 0 \
  --miner.gaslimit  10 \
  --miner.gasprice 1 \
  --gpo.blocks 1 \
  --gpo.percentile 1 \
  --gpo.maxprice 10 \
  --gpo.ignoreprice 2 \
  --dev.gaslimit 100000000000
```

To create the mock blocks, simply run the `create-test-blocks` script. If you want to see which opcodes are called and which ones are not called by the `Snowball` and `Storage` contracts, use the `opcodes` script.
