# 🟣 Polygon Notebook

## Table of contents

- [Research](#research)
- [Systems](#systems)
- [Tools](#tools)
- [Operations](#operations)

## Research

- [🖼️ NFT Mint Analysis](research/nft-mint-analysis/README.md): An approach to comprehending the capacity of our network through the example of a gaming company that performs a certain quantity of NFT mints per day, while adhering to a budget. By examining the expenses associated with minting on various blockchain networks, we could establish the feasibility of the project and select the most suitable alternative for the company.
- [📈 Gas Fee Spikes Analysis](research/gas-fee-spikes-analysis/README.md): The investigation focuses on the sudden surges in fees observed on the Polygon PoS chain in March 2023. It involves examining transaction prices, their connection to EIP-1599, and a thorough examination of a seemingly suspicious smart contract that ultimately reveals itself as an arbitrage bot network.
- [🏎️ Go Data Races](research/go-data-races/README.md): A deep dive into data races, among one of the most common and hardest to debug types of bugs in concurrent systems. A data race occurs when two goroutines access the same variable concurrently and at least one of the accesses is a write.

## Systems

- [⚙️ Zero Prover Overview](systems/zero-prover/README.md): Break down the system using diagrams to understand how it works and what it is used for.
- [⚡️ zkEVM Education Series](https://drive.google.com/drive/u/1/folders/1X1A-00w2L07CJUC7KPeNqAsdw0e50m_i): A detailed course on zkEVM and its various components (prover, aggregator, sequencer, etc.).

## Tools

- [🗒️ Generate Traces for EVM Transactions and Blocks](tools/EVM_TRACER.md): Simple way of generating standard traces using [geth](https://github.com/ethereum/go-ethereum)'s built-in tracers.

## Operations

- [🐳 VM Setup Playbook for Docker PoS](ops/DOCKER_POS_VM_SETUP.md): A simple playbook to set up an Ubuntu 22.04 VM with all the dependencies needed to build the docker images with instrumentation and to run the entire system.

- [🤖 Zero Prover VM Setup](ops/ZERO_PROVER_VM_SETUP.md): Same thing as the VM setup playbook for Docker PoS but for [zero provers](https://github.com/mir-protocol/zero-provers).
