// SPDX-License-Identifier: MIT
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import {Counter} from "../Exercise.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is Counter {
    Counter counter;

    function beforeAll() public {
        // <instantiate contract>
        counter = new Counter();
    }

    function checkCount() public returns (bool) {
        return Assert.equal(counter.get(), 0, "Count value is not 0");
    }

    function checkIncrement() public returns (bool) {
        counter.increment();
        return Assert.equal(counter.get(), 1, "Count value is not 1");
    }

    function checkDecrement() public returns (bool) {
        counter.decrement();
        return Assert.equal(counter.get(), 0, "Count value is not 0");
    }
}