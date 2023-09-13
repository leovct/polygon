// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract AddressStorage {
    address public a;

    function setAddress(address _a) public {
        a = _a;
    }
}
