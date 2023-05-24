// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import '../src/OpenZeppelinERC721NFT.sol';
import '../src/SolmateNFT.sol';
import '../src/ERC721ANFT.sol';
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
  ERC721ANFT erc721aNFTContract;

  // OpenZeppelinERC721
  function testOpenZeppelinERC721Mint() public {
    openZeppelinNFTContract = new OpenZeppelinERC721NFT(name, symbol, uri);
    console2.log('OpenZeppelinNFT contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _openZeppelinERC721Mint(i);
    }
  }

  function _openZeppelinERC721Mint(uint256 _id) internal {
    startMeasuringGas('OpenZeppelinNFT.mintTo()');
    checkpointGasLeft = gasleft();
    uint256 id = openZeppelinNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('OpenZeppelinNFT: New NFT minted (id=%d)', id);
  }

  // Solmate
  function testSolmateMint() public {
    solmateNFTContract = new SolmateNFT(name, symbol, uri);
    console2.log('SolmateNFT contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _solmateMint(i);
    }
  }
  
  function _solmateMint(uint256 _id) internal {
    startMeasuringGas('SolmateNFT.mintTo()');
    uint256 id = solmateNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('SolmateNFT: New NFT minted (id=%d)', id);
  }

  // ERC721A
  function testERC721AMint() public {
    erc721aNFTContract = new ERC721ANFT(name, symbol, uri);
    console2.log('ERC721ANFT contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _erc721aMint(i);
    }
  }
  
  function _erc721aMint(uint256 _id) internal {
    startMeasuringGas('ERC721ANFT.mintTo()');
    uint256 id = erc721aNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('ERC721ANFT: New NFT minted (id=%d)', id);
  }
}
