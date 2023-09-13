// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract EnumStorage {
  enum Status {
    Inactive,
    Active,
    Pending
  }

  Status public status;

  function setStatus(Status _status) public {
    status = _status;
  }
}
