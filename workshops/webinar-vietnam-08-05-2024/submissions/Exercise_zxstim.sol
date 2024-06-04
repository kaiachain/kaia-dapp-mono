// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// There are 3 functions in this Counter contract. Each function has a mistake that you have to fix to be able to pass all the test cases in the test file

contract Counter {
    uint256 public count;

    // Function to get the current count. Make sure the function doesn't modify the value of count.
    function get() public view returns (uint256) {
        return count;
    }

    // Function to increment count by 1
    function increment() public {
        count -= 1;
    }

    // Function to decrement count by 1
    function decrement() public {
        count += 1;
    }
}