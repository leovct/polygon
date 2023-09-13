// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract UintStorage {
    uint8 public ui8;
    uint16 public ui16;
    uint32 public ui32;
    uint64 public ui64;
    uint128 public ui128;
    uint256 public ui256;

    function setUint8(uint8 _ui8) public {
        ui8 = _ui8;
    }

    function setUint16(uint16 _ui16) public {
        ui16 = _ui16;
    }

    function setUint32(uint32 _ui32) public {
        ui32 = _ui32;
    }

    function setUint64(uint64 _ui64) public {
        ui64 = _ui64;
    }

    function setUint128(uint128 _ui128) public {
        ui128 = _ui128;
    }

    function setUint256(uint256 _ui256) public {
        ui256 = _ui256;
    }
}
