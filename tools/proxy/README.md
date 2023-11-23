# Proxy

A lightweight HTTP server, implemented in Go, offering the flexibility to toggle batch request support on the fly using a command-line flag.

## Usage

Run the server and optionally disable batch requests by using the `--disable-batch-request` flag.

```bash
$ go run main.go
Server listening on :8080
Request received: [{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber"},{"jsonrpc":"2.0","id":2,"method":"eth_blockNumber"}]
Response received: [{"jsonrpc":"2.0","id":1,"result":"0x0"},{"jsonrpc":"2.0","id":2,"result":"0x0"}]

Request received: [{"jsonrpc":"2.0","id":2,"method":"eth_getBlockByNumber","params":["0x0",true]}]
Response received: [{"jsonrpc":"2.0","id":2,"result":{"baseFeePerGas":"0x3b9aca00","difficulty":"0x0","extraData":"0x","gasLimit":"0x174876e800","gasUsed":"0x0","hash":"0x735d8b2022e53762a40db90b00a19d5080269738427483553e2cc4b7946e64fb","logsBloom":"0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","miner":"0x0000000000000000000000000000000000000000","mixHash":"0x0000000000000000000000000000000000000000000000000000000000000000","nonce":"0x0000000000000000","number":"0x0","parentHash":"0x0000000000000000000000000000000000000000000000000000000000000000","receiptsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421","sha3Uncles":"0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347","size":"0x221","stateRoot":"0x6ff818de9ef9b4588619b156e164ba302d480e82ea0d688c87e8ec93cd255746","timestamp":"0x0","totalDifficulty":"0x0","transactions":[],"transactionsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421","uncles":[],"withdrawals":[],"withdrawalsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}}]
...
```

```bash
$ go run main.go -disable-batch-request
Server listening on :8080
Request received: [{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber"},{"jsonrpc":"2.0","id":2,"method":"eth_blockNumber"}]
Response received: [{"jsonrpc":"2.0","id":1,"result":"0x0"},{"jsonrpc":"2.0","id":2,"result":"0x0"}]

Request received: [{"jsonrpc":"2.0","id":2,"method":"eth_blockNumber"},{"jsonrpc":"2.0","id":2,"method":"eth_blockNumber"}]
Batch requests are not authorised!
```

```bash
$ go run main.go --help
Usage of /var/folders/7m/3_x4ns7557x52hb6vncqkx8h0000gn/T/go-build551301595/b001/exe/main:
  -disable-batch-request
    	Disable batch requests
```
