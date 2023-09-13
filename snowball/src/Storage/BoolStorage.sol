// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract BoolStorage {
  bool public b;

  function setBool(bool _b) public {
    b = _b;
  }
}
