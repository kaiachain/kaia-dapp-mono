// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import { MyVault } from "../contracts/MyVault.sol";
import { MyToken } from "../contracts/MyToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { console, Test } from "forge-std/Test.sol";

contract ERC4626Test is Test {
    MyVault vault;  
    MyToken myToken;

    function setUp() public {
        console.log("address this: ", address(this));
        myToken = new MyToken(address(this));
        vault = new MyVault(address(myToken));
    }

    function testDeposit() public returns (uint256) {
        uint256 depositAmount = myToken.balanceOf(address(this));
        myToken.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, address(this));
        assertEq(myToken.balanceOf(address(this)), 0);
        assertEq(vault.balanceOf(address(this)), depositAmount);
        return depositAmount;
    }

    function testWithdraw() public {
        uint256 depositAmount = testDeposit();
        uint256 withdrawAmount = depositAmount;
        vault.withdraw(withdrawAmount, address(this), address(this));
        assertEq(myToken.balanceOf(address(this)), withdrawAmount);
        assertEq(vault.balanceOf(address(this)), 0);
    }

    function testRedeem() public {
        uint256 depositAmount = testDeposit();
        uint256 currentShare = vault.balanceOf(address(this));
        uint256 redeemAmount = currentShare / 2;
        vault.redeem(redeemAmount, address(this), address(this));
        assertEq(vault.balanceOf(address(this)), currentShare - redeemAmount);
        console.log(myToken.balanceOf(address(this)));
    }
}