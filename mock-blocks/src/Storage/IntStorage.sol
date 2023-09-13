// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

contract IntStorage {
    int8 public i8;
    int16 public i16;
    int32 public i32;
    int64 public i64;
    int128 public i128;
    int256 public i256;

    function setInt8(int8 _i8) public {
        i8 = _i8;
    }

    function setInt16(int16 _i16) public {
        i16 = _i16;
    }

    function setInt32(int32 _i32) public {
        i32 = _i32;
    }

    function setInt64(int64 _i64) public {
        i64 = _i64;
    }

    function setInt128(int128 _i128) public {
        i128 = _i128;
    }

    function setInt256(int256 _i256) public {
        i256 = _i256;
    }
}
