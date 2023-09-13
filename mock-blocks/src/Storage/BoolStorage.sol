// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

contract BoolStorage {
    bool public b;

    function setBool(bool _b) public {
        b = _b;
    }
}
