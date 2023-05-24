// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import '@erc721a/ERC721A.sol';
import '@openzeppelin/access/Ownable.sol';
import '@openzeppelin/utils/Strings.sol';

error ERC721A_MintPriceNotPaid();
error ERC721A_MaxSupply();
error ERC721A_NonExistentTokenURI();
error ERC721A_WithdrawTransfer();

contract ERC721A_NFT is ERC721A, Ownable {
  using Strings for uint256;

  uint256 public constant TOTAL_SUPPLY = 10_000;
  uint256 public constant MINT_PRICE = 0.08 ether;

  string public baseURI;
  uint256 public currentTokenId;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _baseURI
  ) ERC721A(_name, _symbol) {
    baseURI = _baseURI;
  }

  function mintTo(address recipient) public payable returns (uint256) {
    if (msg.value != MINT_PRICE) {
      revert ERC721A_MintPriceNotPaid();
    }
    uint256 newTokenId = ++currentTokenId;
    if (newTokenId > TOTAL_SUPPLY) {
      revert ERC721A_MaxSupply();
    }
    _mint(recipient, 1);
    return newTokenId;
  }

  function tokenURI(
    uint256 tokenId
  ) public view virtual override returns (string memory) {
    if (ownerOf(tokenId) == address(0)) {
      revert ERC721A_NonExistentTokenURI();
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
      revert ERC721A_WithdrawTransfer();
    }
  }
}
