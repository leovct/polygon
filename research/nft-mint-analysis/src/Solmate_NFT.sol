// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

import {ERC721 as Solmate_ERC721} from '@solmate/tokens/ERC721.sol';
import '@openzeppelin/access/Ownable.sol';
import '@openzeppelin/utils/Strings.sol';

error SolmateMintPriceNotPaid();
error SolmateMaxSupply();
error SolmateNonExistentTokenURI();
error SolmateWithdrawTransfer();

contract Solmate_NFT is Solmate_ERC721, Ownable {
  using Strings for uint256;

  uint256 public constant TOTAL_SUPPLY = 10_000;
  uint256 public constant MINT_PRICE = 0.08 ether;

  string public baseURI;
  uint256 public currentTokenId;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _baseURI
  ) Solmate_ERC721(_name, _symbol) {
    baseURI = _baseURI;
  }

  function mintTo(address recipient) public payable returns (uint256) {
    if (msg.value != MINT_PRICE) {
      revert SolmateMintPriceNotPaid();
    }
    uint256 newTokenId = ++currentTokenId;
    if (newTokenId > TOTAL_SUPPLY) {
      revert SolmateMaxSupply();
    }
    _safeMint(recipient, newTokenId);
    return newTokenId;
  }

  function tokenURI(
    uint256 tokenId
  ) public view virtual override returns (string memory) {
    if (ownerOf(tokenId) == address(0)) {
      revert SolmateNonExistentTokenURI();
    }
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : '';
  }

  function withdrawPayments(address payable payee) external onlyOwner {
    uint256 balance = address(this).balance;
    (bool transferTx, ) = payee.call{value: balance}('');
    if (!transferTx) {
      revert SolmateWithdrawTransfer();
    }
  }
}
