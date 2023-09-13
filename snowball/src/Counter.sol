// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
  uint256 public number;

  function setNumber(uint256 newNumber) public {
    number = newNumber;
  }

  function increment() public returns (uint256) {
    number++;
    return number;
  }

  function tryRevert() public {
    number++;
    revert();
  }

  function terminate(address payable addr) public {
    selfdestruct(addr);
  }

  function stop() public {
    number++;
    assembly {
      stop()
    }
  }
}
