// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

contract MappingStorage {
  mapping(address => uint256) public balances;
  mapping(address => string) public names;
  mapping(address => uint256[]) public favoriteNumbers;

  function setBalance(address _address, uint256 _balance) public {
    balances[_address] = _balance;
  }

  function setName(address _address, string memory _name) public {
    names[_address] = _name;
  }

  function addFavoriteNumber(address _address, uint256 _number) public {
    favoriteNumbers[_address].push(_number);
  }
}
