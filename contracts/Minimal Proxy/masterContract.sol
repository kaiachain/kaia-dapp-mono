// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MasterContract {
    uint public value;

    function setValue(uint _value) external {
        value = _value;
    }
}
