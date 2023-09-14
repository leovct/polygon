// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import './AddressStorage.sol';
import './ArrayStorage.sol';
import './BoolStorage.sol';
import './BytesStorage.sol';
import './EnumStorage.sol';
import './IntStorage.sol';
import './MappingStorage.sol';
import './StringStorage.sol';
import './UintStorage.sol';

// Contract that stores values of any types.
contract Storage is
  AddressStorage,
  ArrayStorage,
  BoolStorage,
  BytesStorage,
  EnumStorage,
  IntStorage,
  MappingStorage,
  StringStorage,
  UintStorage
{
  function store() public {
    setAddress(0xF135B9eD84E0AB08fdf03A744947cb089049bd79);

    pushToUintArray(uint256(1));
    pushToUintArray(uint256(2));
    pushToUintArray(uint256(3));
    pushToStringArray('this');
    pushToStringArray('is');
    pushToStringArray('awesome');
    pushToBytes32Array('this');
    pushToBytes32Array('is');
    pushToBytes32Array('great');
    pushToBoolArray(false);
    pushToBoolArray(true);
    pushToBoolArray(true);

    setBool(true);

    setByte1('a');
    setByte2('ab');
    setByte3('abc');
    setByte4('abcd');
    setByte5('abcde');
    setByte6('abcdef');
    setByte7('abcdefg');
    setByte8('abcdefgh');
    setByte9('abcdefghi');
    setByte10('abcdefghij');
    setByte11('abcdefghijk');
    setByte12('abcdefghijkl');
    setByte13('abcdefghijklm');
    setByte14('abcdefghijklmn');
    setByte15('abcdefghijklmno');
    setByte16('abcdefghijklmnop');
    setByte17('abcdefghijklmnopq');
    setByte18('abcdefghijklmnopqr');
    setByte19('abcdefghijklmnopqrs');
    setByte20('abcdefghijklmnopqrst');
    setByte21('abcdefghijklmnopqrstu');
    setByte22('abcdefghijklmnopqrstuv');
    setByte23('abcdefghijklmnopqrstuvw');
    setByte24('abcdefghijklmnopqrstuvwx');
    setByte25('abcdefghijklmnopqrstuvwxy');
    setByte26('abcdefghijklmnopqrstuvwxyz');
    setByte27('abcdefghijklmnopqrstuvwxyz1');
    setByte28('abcdefghijklmnopqrstuvwxyz12');
    setByte29('abcdefghijklmnopqrstuvwxyz123');
    setByte30('abcdefghijklmnopqrstuvwxyz1234');
    setByte31('abcdefghijklmnopqrstuvwxyz12345');
    setByte32('abcdefghijklmnopqrstuvwxyz123456');

    setStatus(Status.Inactive);

    setInt8(1);
    setInt16(2);
    setInt32(3);
    setInt64(4);
    setInt128(5);
    setInt256(6);

    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x6);
    setBalance(alice, 10);
    setBalance(bob, 20);
    setBalance(charlie, 30);
    setName(alice, 'alice');
    setName(bob, 'bob');
    addFavoriteNumber(alice, 7);
    addFavoriteNumber(bob, 2);

    setString('ethereum');

    setUint8(1);
    setUint16(2);
    setUint32(3);
    setUint64(4);
    setUint128(5);
    setUint256(6);
  }
}
