# 🦄 Integrating [UniswapV3](https://uniswap.org/whitepaper-v3.pdf) into [polygon-cli](https://github.com/maticnetwork/polygon-cli)

## Table of contents

- [Introduction](#introduction)
- [Deploying UniswapV3 in Go](#deploying-uniswapv3-in-go)
- [UniswapV3 Load Test Example](#uniswapv3-load-test-example)

## Introduction

The DevTools team at Polygon Labs is working on a fascinating project called [polygon-cli](https://github.com/maticnetwork/polygon-cli). It is a tool made to make your life easier when interacting with blockchains, quite similar to [cast](https://book.getfoundry.sh/cast/) but with a different feature set.

One standout feature of polygon-cli is its ability to conduct generic load tests on RPC endpoints, allowing for configurable load scenarios. This spans from simple ETH transfers to more complex tasks like ERC20/ERC721 transfers, invoking random opcodes in a designated contract, interacting with precompiles, storing random data in a smart contract, and simulating RPC traffic. It is an impressively comprehensive tool, but there was one missing piece— a [UniswapV3](https://app.uniswap.org/swap)-like load test. The idea is to replicate real-world traffic using polygon-cli, and considering UniswapV3's extensive usage across platforms (on Ethereum and L2 chains like Polygon), we aim to integrate it into polygon-cli.

## Deploying UniswapV3 in Go

We started to look at documentation on UniswapV3 in order to deploy it locally on our devnets. It is not a trivial process, involving over 15 steps, numerous contracts, configurations, and dependencies. Thankfully, the Uniswap team created a [CLI](https://github.com/Uniswap/deploy-v3) for deploying UniswapV3 on any Ethereum-compatible network. Our task was to translate these Typescript scripts into Go, and while the overall process went smoothly, we did encounter and document some challenges.

The process unfolded as follows:

1. **Identifying all the [contracts](https://github.com/maticnetwork/polygon-cli/tree/aed352b9abfe829ada718509668db37e5f94609b/contracts/uniswapv3) involved in UniswapV3 deployment**.

This involved navigating through various repositories, such as [v3-core](https://github.com/Uniswap/v3-core), [v3-periphery](https://github.com/Uniswap/v3-periphery), [v3-staker](https://github.com/Uniswap/v3-staker), [v3-router](https://github.com/Uniswap/v3-router) and other contracts from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts) and [WETH9](https://github.com/gnosis/canonical-weth/blob/master/contracts/WETH9.sol). The challenge lay in dealing with different tag versions and repositories, introducing an element of error-prone complexity.

2. **Generating go bindings for those contracts using [`forge`](https://github.com/foundry-rs/foundry)**.

Initially, we attempted to use [`abigen`](https://pkg.go.dev/github.com/synapsecns/sanguine/tools/abigen#section-readme), but faced issues with linking dependencies in [`NonfungibleTokenPositionDescriptor.sol`](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/NonfungibleTokenPositionDescriptor.sol). The contract uses a library called [`NFTDescriptor`](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/NonfungibleTokenPositionDescriptor.sol#L48-L93) but it does not take a parameter for the address of the library in the [`constructor`](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/NonfungibleTokenPositionDescriptor.sol#L29-L32) method which makes it a pain to deploy! This means that the tool used to generate the go bindings needs to handle linking the library address in `NonfungibleTokenPositionDescriptor` bytecode by itself. Otherwise, there will be issues when trying to interact with the contracts.

3. **Implementing the [15 steps](https://github.com/maticnetwork/polygon-cli/blob/aed352b9abfe829ada718509668db37e5f94609b/cmd/loadtest/uniswapv3/deploy.go) of the UniswapV3 deployment in Go**.

While not very difficult, it was a lengthy process that required careful deployment order.

4. **[Setting up a liquidity pool](https://github.com/maticnetwork/polygon-cli/blob/aed352b9abfe829ada718509668db37e5f94609b/cmd/loadtest/uniswapv3/pool.go) which involves creating a new pool, initialising it and providing liquidity**.

This is the most complex part of the deployment.

- Creating a pool is a straightforward task, requiring the addresses of two ERC20 tokens and a fee amount. It is crucial to ensure that the fee aligns with one of the [pool fee tiers](https://docs.uniswap.org/concepts/protocol/fees) – 0.05%, 0.30%, or 1%. Additionally, make sure the fee amount is correctly formatted in hundredths of a bip (basis point).

- Initialising a pool introduces more complexity, involving setting the initial price of the pool in a specific notation known as [Q64.96](https://uniswapv3book.com/docs/milestone_3/more-on-fixed-point-numbers/). For a detailed understanding, [Jeiwan](https://twitter.com/jeiwan7) provides excellent explanations in his [UniswapV3 Book](https://uniswapv3book.com/docs/milestone_1/calculating-liquidity/). This is a great resource to undestand how UniswapV3 works under the hood.

- Providing liquidity poses its own set of challenges:

  - As a liquidity provider, specifying the price range for liquidity provision (upper and lower ticks) can be complex. It is also essential to ensure that [tick values are multiples of the default tick spacing](https://github.com/maticnetwork/polygon-cli/blob/aed352b9abfe829ada718509668db37e5f94609b/cmd/loadtest/uniswapv3/pool.go#L190-L191) (or override it) to avoid errors.

  - When providing liquidity, give allowances to the involved contracts and ensure sufficient token balances. This is straightforward, but it is easy to overlook! Also, make sure to reserve a portion of your tokens for swapping. If you use up all your tokens during the minting process, you will not have any left for conducting swaps.

  - Consider the operation deadline, the Unix time after which the minting will fail, to safeguard against prolonged transactions and volatile price swings. If you set it too low, it may cause problems but too high is not advisable neither, especially in production.

  - Maintain slippage protection by setting minimum acceptable amounts of token0 and token1 during minting to prevent potential token loss. While this may be less critical in a devnet setup, it is crucial in testnet or production environments.

5. **[Performing swaps](https://github.com/maticnetwork/polygon-cli/blob/aed352b9abfe829ada718509668db37e5f94609b/cmd/loadtest/uniswapv3/swap.go)**.

A relatively straightforward step. Just remember to establish a minimum amount to guard against slippage, and you also have the option to set a limit price for the swap to mitigate potential price impact.

The implementation of the UniswapV3 mode lies [here](https://github.com/maticnetwork/polygon-cli/tree/aed352b9abfe829ada718509668db37e5f94609b/cmd/loadtest/uniswapv3).

## UniswapV3 Load Test Example

1. Start a local devnet (can be `geth`, `anvil` or anything else).

```sh
$ make anvil
...
Listening on 127.0.0.1:8545
```

2. Fund the load test account.

```sh
$eth_coinbase=$(curl -s -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0", "id": 2, "method": "eth_accounts", "params": []}' http://127.0.0.1:8545 | jq -r ".result[0]"); \
	hex_funding_amount=$(echo "obase=16; 1010000000*10^18" | bc); \
	echo $eth_coinbase $hex_funding_amount; \
	curl \
		-H "Content-Type: application/json" \
		-d '{"jsonrpc":"2.0", "method":"eth_sendTransaction", "params":[{"from": "'$eth_coinbase'","to": "0x85da99c8a7c2c95964c8efd687e95e632fc533d6","value": "0x'$hex_funding_amount'"}], "id":1}' \
		-s \
		http://127.0.0.1:8545 | jq
0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 34373D1B5E4818532000000
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x0a72ecd7b2520788aa3c6c8d5fad0bfff93a3ff796a7e0f73f2b74b5e274757d"
}
```

3. Perform UniswapV3 load test.

```sh
$ go run main.go loadtest uniswapv3 --rpc-url http://localhost:8545 --requests 20 --verbosity 500
10:55AM DBG Starting logger in console mode
10:55AM INF Starting Load Test
10:55AM INF Connecting with RPC endpoint to initialize load test parameters
10:55AM DBG Eip-1559 support detected
10:55AM DBG 🦄 Deploying UniswapV3 contracts...
10:55AM DBG Step 0: WETH9 deployment
10:55AM DBG Contract deployed address=0x73a6d49037afd585a0211a7bb4e990116025b45d name=WETH9
10:55AM DBG Step 1: UniswapV3Factory deployment
10:55AM DBG Contract deployed address=0x34cb2c25dd47f344079443cec353290441ac8ac2 name=UniswapV3Factory
10:55AM DBG Step 2: Enable fee amount
10:55AM DBG Fee amount enabled
10:55AM DBG Step 3: UniswapInterfaceMulticall deployment
10:55AM DBG Contract deployed address=0x1eac426c4bb3e850f56176f72b7718b3d3e78845 name=UniswapInterfaceMulticall
10:55AM DBG Step 4: ProxyAdmin deployment
10:55AM DBG Contract deployed address=0x0b589e1cb2457f0ba5a5eef2800d47a4d6fa9fab name=ProxyAdmin
10:55AM DBG Step 5: TickLens deployment
10:55AM DBG Contract deployed address=0xc0019107cb4f79d41fcb00175b9721c32f07879f name=TickLens
10:55AM DBG Step 6: NFTDescriptorLib deployment
10:55AM DBG Contract deployed address=0xc62a8803d4b354601ef705f83713a140ba839984 name=NFTDescriptor
10:55AM DBG Step 7: NFTPositionDescriptor deployment
10:55AM DBG Contract deployed address=0x2daaf9cd807391f156389759d6a647df2cdd0df2 name=NonfungibleTokenPositionDescriptor
10:55AM DBG Step 8: TransparentUpgradeableProxy deployment
10:55AM DBG Contract deployed address=0xdd9534b195e0ae4412d117d9002c3fca10e73178 name=TransparentUpgradeableProxy
10:55AM DBG Step 9: NonfungiblePositionManager deployment
10:55AM DBG Contract deployed address=0xa909b7126e953e4f752e481333067039bcde7614 name=NonfungiblePositionManager
10:55AM DBG Step 10: V3Migrator deployment
10:55AM DBG Contract deployed address=0x9c33f001c3e52aa62b56ab25df6e07fb662bc806 name=V3Migrator
10:55AM DBG Step 11: Transfer UniswapV3Factory ownership
10:55AM DBG Factory contract already owned by this address
10:55AM DBG Step 12: UniswapV3Staker deployment
10:55AM DBG Contract deployed address=0x0bd9388405ec8427ec39117a42e3886a20722c5d name=UniswapV3Staker
10:55AM DBG Step 13: QuoterV2 deployment
10:55AM DBG Contract deployed address=0x1c31cf3d81907b3fbeeeaad90c2882592c82f64e name=QuoterV2
10:55AM DBG Step 14: SwapRouter02 deployment
10:55AM DBG Contract deployed address=0xc3f3338ed0fd9c2013bd26c6b4da337858a486a8 name=SwapRouter02
10:55AM DBG Step 15: Transfer ProxyAdmin ownership
10:55AM DBG ProxyAdmin contract already owned by this address
10:55AM DBG UniswapV3 deployed addresses={"FactoryV3":"0x34cb2c25dd47f344079443cec353290441ac8ac2","Migrator":"0x9c33f001c3e52aa62b56ab25df6e07fb662bc806","Multicall":"0x1eac426c4bb3e850f56176f72b7718b3d3e78845","NFTDescriptorLib":"0xc62a8803d4b354601ef705f83713a140ba839984","NonfungiblePositionManager":"0xa909b7126e953e4f752e481333067039bcde7614","NonfungibleTokenPositionDescriptor":"0x2daaf9cd807391f156389759d6a647df2cdd0df2","ProxyAdmin":"0x0b589e1cb2457f0ba5a5eef2800d47a4d6fa9fab","QuoterV2":"0x1c31cf3d81907b3fbeeeaad90c2882592c82f64e","Staker":"0x0bd9388405ec8427ec39117a42e3886a20722c5d","SwapRouter02":"0xc3f3338ed0fd9c2013bd26c6b4da337858a486a8","TickLens":"0xc0019107cb4f79d41fcb00175b9721c32f07879f","TransparentUpgradeableProxy":"0xdd9534b195e0ae4412d117d9002c3fca10e73178","WETH9":"0x73a6d49037afd585a0211a7bb4e990116025b45d"}
10:55AM DBG 🪙 Deploying ERC20 tokens...
10:55AM DBG Minted tokens amount=999999999999999999 recipient=0x85da99c8a7c2c95964c8efd687e95e632fc533d6 token=SwapperA
10:55AM DBG Contract deployed address=0x608dcefe5f08532b886fc1bc5f0c308670ac21fd name=Swapper
10:55AM DBG Allowance set amount=1000000000000000 spenderAddress=0xa909b7126e953e4f752e481333067039bcde7614 spenderName=NFTPositionManager tokenName=SwapperA_SwapperA
10:55AM DBG Allowance set amount=1000000000000000 spenderAddress=0xc3f3338ed0fd9c2013bd26c6b4da337858a486a8 spenderName=SwapRouter02 tokenName=SwapperA_SwapperA
10:55AM DBG Minted tokens amount=999999999999999999 recipient=0x85da99c8a7c2c95964c8efd687e95e632fc533d6 token=SwapperB
10:55AM DBG Contract deployed address=0x623e61f6f60c434bcb97fa7d01c33c17fc039927 name=Swapper
10:55AM DBG Allowance set amount=1000000000000000 spenderAddress=0xa909b7126e953e4f752e481333067039bcde7614 spenderName=NFTPositionManager tokenName=SwapperB_SwapperB
10:55AM DBG Allowance set amount=1000000000000000 spenderAddress=0xc3f3338ed0fd9c2013bd26c6b4da337858a486a8 spenderName=SwapRouter02 tokenName=SwapperB_SwapperB
10:55AM DBG 🎱 Deploying UniswapV3 liquidity pool...
10:55AM DBG Pool created and initialized fees=3000
10:55AM DBG Pool instantiated address=0x9b5b1118d6e3543d72bfa131d3c574ed50d2b007
10:55AM DBG Liquidity provided to the pool liquidity=2000000000000
10:55AM DBG Starting main load test loop currentNonce=64
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Successful swap amountIn=1000 tokenIn=token0 tokenOut=token1
10:55AM DBG Successful swap amountIn=1000 tokenIn=token1 tokenOut=token0
10:55AM DBG Finished main load test loop lastNonce=84 startNonce=64
10:55AM DBG Waiting for remaining transactions to be completed and mined
10:55AM DBG Got final block number currentNonce=84 final block number=85
10:55AM INF * Results
10:55AM INF Samples samples=20
10:55AM INF Start time of loadtest (first transaction sent) startTime=2023-11-06T10:55:41+01:00
10:55AM INF End time of loadtest (final transaction mined) endTime=2023-11-06T10:55:51+01:00
10:55AM INF Estimated tps tps=2.047441244072645
10:55AM INF Mean Wait meanWait between sending transactions=0.0116877354
10:55AM INF Rough test summary final rate limit=4 testDuration (seconds)=9.768290083
10:55AM INF Num errors numErrors=0
10:55AM INF Finished
```

## Conclusion

It was an interesting experience that gave us a better understanding of how UniswapV3 works. It also allowed us to see how complicated and error prone the deployment of DEX really is. It might be interesting to add other protocols that are widely used on Polygon, such as [OpenSea](https://opensea.io/), an NFT marketplace or [Aave](https://aave.com/), a DeFi liquidity protocol.
