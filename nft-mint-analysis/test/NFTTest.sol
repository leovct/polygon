// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import '../src/OpenZeppelinERC721NFT.sol';
import '../src/SolmateNFT.sol';
import '@openzeppelin/utils/Strings.sol';
import '@solmate/test/utils/DSTestPlus.sol';
import '@forge-std/console2.sol';

contract NFTTest is DSTestPlus {
  using Strings for uint256;

  string constant name = 'CryptoUnicorns';
  string constant symbol = 'CU';
  string constant uri = 'https://my.api.io/';
  uint256 constant MINT_PRICE = 0.08 ether;
  uint256 constant NB_NFT_PER_BATCH = 10;

  uint256 checkpointGasLeft;
  OpenZeppelinERC721NFT openZeppelinNFTContract;
  SolmateNFT solmateNFTContract;

  function openZeppelinMint(uint256 _id) public {
    startMeasuringGas('OpenZeppelinNFT.mintTo()');
    checkpointGasLeft = gasleft();
    uint256 id = openZeppelinNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('OpenZeppelinNFT: New NFT minted (id=%d)', id);
  }

  function testOpenZeppelinMint() public {
    openZeppelinNFTContract = new OpenZeppelinERC721NFT(name, symbol, uri);
    console2.log('OpenZeppelinNFT contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      openZeppelinMint(i);
    }
  }

  function solmateMint(uint256 _id) public {
    startMeasuringGas('SolmateNFT.mintTo()');
    uint256 id = solmateNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('SolmateNFT: New NFT minted (id=%d)', id);
  }

  function testSolmateMint() public {
    solmateNFTContract = new SolmateNFT(name, symbol, uri);
    console2.log('SolmateNFT contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      solmateMint(i);
    }
  }
}
