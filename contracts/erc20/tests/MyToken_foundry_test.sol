// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    MyToken public myTestToken;

    function setUp() public {
        myTestToken = new MyToken(address(1));
    }

    function test_TotalSupplyEqualsOwnersBalance() public {
        assertEq(myTestToken.totalSupply(), myTestToken.balanceOf(address(1)));
    }

    function testTransferBetweenAccounts() public {
        vm.prank(address(1));
        myTestToken.transfer(address(2), 500000000000000000000);
        assertEq(myTestToken.balanceOf(address(1)), 500000000000000000000);
        assertEq(myTestToken.balanceOf(address(2)), 500000000000000000000);
    }
    
    function testFailTransferInsufficientBalance() external {
        vm.prank(address(1));
        myTestToken.transfer(address(2), 10000000000000000000000); 
    }
}
