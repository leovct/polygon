// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract StringStorage {
  string public s;

  function setString(string memory _s) public {
    s = _s;
  }
}
