// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ArrayStorage {
    uint256[] public uintArray;
    string[] public stringArray;
    bytes32[] public bytes32Array;
    bool[] public boolArray;

    function pushToUintArray(uint256 _value) public {
        uintArray.push(_value);
    }

    function pushToStringArray(string memory _value) public {
        stringArray.push(_value);
    }

    function pushToBytes32Array(bytes32 _value) public {
        bytes32Array.push(_value);
    }

    function pushToBoolArray(bool _value) public {
        boolArray.push(_value);
    }
}
