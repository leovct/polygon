# ⛽️ NFT Gas Analysis

## 📌 Introduction

We'd like to understand Polygon PoS "capacity".

> TODO: Explain what capacity means?

One way to understand the capacity of our network would be to take a real-use case, e.g. a gaming company that does `x` NFT mints a day with a budget of $`y`. By analyzing the cost of minting on different blockchain networks, we could determine if it is feasible and identify the most suitable option for the company.

## 🕵️ Analysis

Minting an NFT involves recording unique digital content onto a blockchain network, which comes at a cost. Users need to pay fees to compensate the network's validators or miners for verifying and processing the transaction. The cost of minting an NFT depends on several factors, including:

1. The blockchain network being used  
  Different blockchain networks have varying fees for minting NFTs. For example, Ethereum, one of the most popular blockchain networks for NFTs, has a fee referred to as "gas" that is based on the network's congestion and the complexity of the transaction. While Solana's fees are fixed and very low, typically less than a penny per transaction, thanks to its unique architecture, which allows it to process transactions in parallel and in a highly efficient manner.
2. The size and complexity of the digital content  
  The larger and more complex the digital content, the more resources it will require to add it to the blockchain network, resulting in a higher fee.
3. The current market conditions  
  The demand for minting NFTs can fluctuate depending on the current market conditions. During times of high demand, the fees may increase due to increased network congestion.

The total cost of a transaction can be calculated by multiplying the gas price in Gwei by the gas units used by the transaction. During times of high demand, the fees may increase due to increased network congestion.

### What's the gas cost of minting an NFT?

The gas cost of minting an NFT on Ethereum or any other EVM-compatible network is measured in "gas units", which represent the amount of computational work required to execute a transaction. Each operation on the EVM has a fixed gas cost associated with it, and the total gas cost of a transaction is the sum of the gas costs of all the operations that make up the transaction.

A simple mint function that adds a new token to a contract and updates the contract's storage may require a gas cost of around [30,000 to 100,000](#annex) gas units, while a more complex mint function that involves expensive calculations may require significantly more gas units.

The gas price is denominated in Gwei, which is a sub-unit of Ethereum's native currency, Ether (ETH). One Gwei is equal to 0.000000001 ETH, so the cost of gas in ETH can be calculated by multiplying the gas price in Gwei by the gas units used by the transaction. For example, if the gas price is 50 Gwei and the transaction uses 100,000 gas units, the cost of the transaction would be 0.005 ETH (`50 Gwei * 100,000 gas units * 0.000000001 ETH/Gwei = 0.005 ETH`).

## Simulation of gas mint prices on different blockchain networks

Questions:
- What happens if gas fees go up?
- What happens if MATIC token value goes up?

Networks:
- Ethereum
- Polygon PoS
- Optimism
- Arbitrum
- Immutable
- Polygon zkEVM
- zkSync
- etc.

## Annex

As an example, let's consider two basic NFT smart contracts - one implemented using [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)'s ERC721 standard and the other using [Solmate](https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol), a gas-optimized version. These contracts involve adding a new token and updating the contract storage, which cost between 30,000 and 100,000 gas units.

```sh
$ make test
forge test -vvv
[⠆] Compiling...
No files changed, compilation skipped

Running 2 tests for test/NFTTest.sol:NFTTest
[PASS] testOpenZeppelinMint() (gas: 1869743)
Logs:
  OpenZeppelinNFT contract deployed
  OpenZeppelinNFT.mintTo() Gas: 103964
  OpenZeppelinNFT: New NFT minted (id=1)
  OpenZeppelinNFT.mintTo() Gas: 33264
  OpenZeppelinNFT: New NFT minted (id=2)
  ...
  OpenZeppelinNFT.mintTo() Gas: 33264
  OpenZeppelinNFT: New NFT minted (id=10)

[PASS] testSolmateMint() (gas: 1668009)
Logs:
  SolmateNFT contract deployed
  SolmateNFT.mintTo() Gas: 81508
  SolmateNFT: New NFT minted (id=1)
  SolmateNFT.mintTo() Gas: 32808
  SolmateNFT: New NFT minted (id=2)
  ...
  SolmateNFT.mintTo() Gas: 32808
  SolmateNFT: New NFT minted (id=10)

Test result: ok. 2 passed; 0 failed; finished in 1.09ms
```
