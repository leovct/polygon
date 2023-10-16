# 🗒️ Generate Traces for EVM Transactions and Blocks

This is a very simple way of generating traces using geth built-in tracers.

[Tracing](https://geth.ethereum.org/docs/developers/evm-tracing) allows users to examine precisely what was executed by the EVM during some specific transaction or set of transactions. In its simplest form, tracing a transaction entails requesting the Ethereum node to reexecute the desired transaction with varying degrees of data collection and have it return an aggregated summary.

The [simplest](https://geth.ethereum.org/docs/developers/evm-tracing/basic-traces) type of transaction trace that Geth can generate are raw EVM opcode traces but the tracing API also accepts an optional `tracer` parameter that defines how the data returned to the API call should be processed. Geth comes bundled with a choice of tracers that can be invoked via the [tracing](https://geth.ethereum.org/docs/interacting-with-geth/rpc/ns-debug) API. It's also possible to implement [custom](https://geth.ethereum.org/docs/developers/evm-tracing#custom-tracers) tracers in Javascript or Go.

The built-in tracer we use here is called the [prestate](https://geth.ethereum.org/docs/developers/evm-tracing/built-in-tracers#prestate-tracer) tracer. This tracer returns the accounts necessary to execute a given transaction. It reexecutes the given transaction and tracks every part of state that is touched. The result is an object. The keys are addresses of accounts. The values is an object with the following fields:

- `balance` (`string`) which represents the account balance in Wei.
- `nonce` (`uint64`) which represents the account nonce.
- `code` (`string`) which represents the hex-encoded account bytecode (if there's any).
- `storage` (`map[string]string`) which represents the storage slots of the contract (if there's any).

## Transaction

Easily generate a trace for any transaction by providing its hash, such as the example below.

```sh
$ curl \
  --header "Content-Type: application/json" \
  --data '{"id": 1, "jsonrpc": "2.0", "method": "debug_traceTransaction", "params": ["0x57a022f6534b19086aa97c279df52ef64ca7767dc8850a32c07ebc5c29a5646b", {"tracer": "prestateTracer"}]}' \
  --silent \
  localhost:8545 | jq .result
{
  "0x0000000000000000000000000000000000000000": {
    "balance": "0x44db13b845"
  },
  "0x0000000000000000000000000000000000000008": {
    "balance": "0x1"
  },
  "0x6fda56c57b0acadb96ed5624ac500c0429d59429": {
    "balance": "0x0",
    "code": "0x...",
    "nonce": 1
  },
  "0x85da99c8a7c2c95964c8efd687e95e632fc533d6": {
    "balance": "0x10f0ce577c51c561ed8",
    "nonce": 28
  }
}
```

Generate a trace for the first transaction of the last block with a simple command.

```sh
$ curl \
  --header "Content-Type: application/json" \
  --data '{"id": 1, "jsonrpc": "2.0", "method": "debug_traceTransaction", "params": ["'"$(cast block --json | jq -r '.transactions[0]')"'", {"tracer": "prestateTracer"}]}' \
  --silent \
  localhost:8545 | jq .result
{
  "0x0000000000000000000000000000000000000000": {
    "balance": "0x43bc193c64b"
  },
  "0x0000000000000000000000000000000000000001": {
    "balance": "0x1"
  },
  "0x6fda56c57b0acadb96ed5624ac500c0429d59429": {
    "balance": "0x0",
    "code": "0x...",
    "nonce": 1
  },
  "0x85da99c8a7c2c95964c8efd687e95e632fc533d6": {
    "balance": "0x10f0a5503a765966448",
    "nonce": 1963
  }
}
```

## Block

The same functionality extends to blocks, allowing you to generate traces effortlessly. Under the hood, it returns a list of traces, one for each transaction that make the block. Here's how you can generate a trace for the last block.

```sh
$ n=$(cast bn) && curl \
  --header "Content-Type: application/json" \
  --data '{"id": 1, "jsonrpc": "2.0", "method": "debug_traceBlockByNumber", "params": ["'"$(printf '0x%x\n' $n)"'", {"tracer": "prestateTracer"}]}' \
  --silent \
  localhost:8545 | jq .result > "block_$n.json"
[
  {
    "txHash": "0xffe3ca4327e56761d82d653330834ba0960ffd04a56fe37e72b8eb18c633335b",
    "result": {
      "0x0000000000000000000000000000000000000000": {
        "balance": "0x4b462ea9491"
      },
      "0x0000000000000000000000000000000000000003": {
        "balance": "0x1"
      },
      "0x1eaacfde4c6b27eb81d3e9b654193f3a343f14ea": {
        "balance": "0x0",
        "code": "0x...",
        "nonce": 1
      },
      "0x85da99c8a7c2c95964c8efd687e95e632fc533d6": {
        "balance": "0x10efee2d9bc86380ea6",
        "nonce": 10414
      }
    }
  },
  {
    "txHash": "0x8786cb9409db0591f3ebe60d4fddd1bd26d2b4b86e47cf3553a431c1f5bd315a",
    "result": {
      "0x0000000000000000000000000000000000000000": {
        "balance": "0x4b462ed1c73"
      },
      "0x1eaacfde4c6b27eb81d3e9b654193f3a343f14ea": {
        "balance": "0x0",
        "code": "0x...",
        "nonce": 1,
        "storage": {
          "0x0000000000000000000000000000000000000000000000000000000000000000": "0x0000000000000000000000000000000000000000000000000000deadbeef00cd"
        }
      },
      "0x85da99c8a7c2c95964c8efd687e95e632fc533d6": {
        "balance": "0x10efee2d9bc863245c6",
        "nonce": 10415
      }
    }
  },
  ...
]
```

To go further, we could build a custom tool that would aggregate those traces to generate a unified block trace. There could be challenges such as conflicts when multiple transactions, within the same block, attempt to modify the same state (`account`, `storage` or `nonce`) in different ways. Here are a few examples.

- Two transactions attempt to change the balance of the same account differently.
- Or to increment the nonce of the same account differently.
- Or to modify the same storage slot of a contract differently.
- Or if a contract is created (or deleted) and called in the same block.

To handle those issues, a solution would be to iterate over the traces in the order of the transactions in the block. Each time a conflict arises, we accept the change made by the last transaction in order.
