## 🧱 Mock blocks

## Table of contents

- [Introduction](#introduction)
- [Usage](#usage)

## Introduction

We would like to be able to generate a list of blocks that represent the activity of the Polygon chain. These mock blocks would then be used to check that the zero-prover can generate proofs for all these types of transactions (native, erc20 and erc721 transfers, contract deployments of different sizes, contract interactions, storage writes of any types, call most of the opcodes of the EVM, etc.).

## Usage

Simply run the script: `./create-test-blocks.sh`.
