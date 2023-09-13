## Mock blocks

## Table of contents

TODO

## Introduction

We would like to be able to generate a list of blocks that represent the activity of the Polygon chain. These mock blocks would then be used to check that the zero-prover can generate proofs for all these types of transactions (native, erc20 and erc721 transfers, contract deployments of different sizes, contract interactions, storage writes of any types, call most of the opcodes of the EVM, etc.).

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
