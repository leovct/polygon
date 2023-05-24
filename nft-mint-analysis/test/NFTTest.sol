// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import '../src/OpenZeppelinERC721_NFT.sol';
import '../SRC/OpenZeppelinERC721Enumerable_NFT.sol';
import '../src/Solmate_NFT.sol';
import '../src/ERC721A_NFT.sol';
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
  OpenZeppelinERC721_NFT openZeppelinERC721NFTContract;
  OpenZeppelinERC721Enumerable_NFT openZeppelinERC721EnumerableNFTContract;
  Solmate_NFT solmateNFTContract;
  ERC721A_NFT erc721aNFTContract;

  // OpenZeppelinERC721
  function testOpenZeppelinERC721Mint() public {
    openZeppelinERC721NFTContract = new OpenZeppelinERC721_NFT(
      name,
      symbol,
      uri
    );
    console2.log('Contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _openZeppelinERC721Mint(i);
    }
  }

  function _openZeppelinERC721Mint(uint256 _id) internal {
    startMeasuringGas('mintTo()');
    checkpointGasLeft = gasleft();
    uint256 id = openZeppelinERC721NFTContract.mintTo{value: MINT_PRICE}(
      address(1)
    );
    stopMeasuringGas();
    assert(id == _id);
    console2.log('New NFT minted (id=%d)', id);
  }

  // OpenZeppelinERC721Enumerable
  function testOpenZeppelinERC721EnumerableMint() public {
    openZeppelinERC721EnumerableNFTContract = new OpenZeppelinERC721Enumerable_NFT(
      name,
      symbol,
      uri
    );
    console2.log('Contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _openZeppelinERC721EnumerableMint(i);
    }
  }

  function _openZeppelinERC721EnumerableMint(uint256 _id) internal {
    startMeasuringGas('mintTo()');
    checkpointGasLeft = gasleft();
    uint256 id = openZeppelinERC721EnumerableNFTContract.mintTo{
      value: MINT_PRICE
    }(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('New NFT minted (id=%d)', id);
  }

  // Solmate
  function testSolmateMint() public {
    solmateNFTContract = new Solmate_NFT(name, symbol, uri);
    console2.log('Contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _solmateMint(i);
    }
  }

  function _solmateMint(uint256 _id) internal {
    startMeasuringGas('mintTo()');
    uint256 id = solmateNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('New NFT minted (id=%d)', id);
  }

  // ERC721A
  function testERC721AMint() public {
    erc721aNFTContract = new ERC721A_NFT(name, symbol, uri);
    console2.log('Contract deployed');

    for (uint256 i = 1; i <= NB_NFT_PER_BATCH; i++) {
      _erc721aMint(i);
    }
  }

  function _erc721aMint(uint256 _id) internal {
    startMeasuringGas('mintTo()');
    uint256 id = erc721aNFTContract.mintTo{value: MINT_PRICE}(address(1));
    stopMeasuringGas();
    assert(id == _id);
    console2.log('New NFT minted (id=%d)', id);
  }
}
