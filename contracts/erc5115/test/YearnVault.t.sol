// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.20;

import "../src/samples/YearnVaultSY.sol";
import {Test, console} from "forge-std/Test.sol";

contract YearnVaultSYTest is Test {
    address _underlying = 0x7CAc58eB7707A83a196D73A4414C665a631Cd585;
    address _yvToken = 0x3D63B4766B873F2eEb473ca3545AFda6b0A10BCD;
    address myWallet = 0xE41D71FD117236209C25a4C4e67A51d3966B1a84;

    YearnVaultSY yearnVaultSY;

    function setUp() public {
        yearnVaultSY = new YearnVaultSY("YearnVaultSY", "YVSY", _underlying, _yvToken);
    }

    function testDeposit() public {
        hoax(myWallet);
        console.log("SY address: ", address(yearnVaultSY));
        _underlying.call(abi.encodeWithSignature("approve(address,uint256)", address(yearnVaultSY), 100));
        vm.prank(myWallet);
        console.log("Deposited: ", yearnVaultSY.deposit(myWallet, _underlying, 100, 100));
    }

    function testRedeem() public {
        testDeposit();
        hoax(myWallet);
        yearnVaultSY.approve(myWallet, 100);
        vm.prank(myWallet);
        console.log("Redeemed: ", yearnVaultSY.redeem(myWallet, 50, _underlying, 50));
        vm.prank(myWallet);
        console.log("Redeemed: ", yearnVaultSY.redeem(myWallet, 50, _yvToken, 50));
    }
}
