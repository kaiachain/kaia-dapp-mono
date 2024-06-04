// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "hardhat/console.sol";
import "../contracts/erc20.sol";


contract ERC20Test is MyToken(TestsAccounts.getAccount(0)) {
    /// Define variables referring to different accounts
    address acc0;
    address acc1;
    address acc2;

    MyToken myTokenToTest;

    function beforeAll () public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);

        myTokenToTest = new  MyToken(acc0);
    }

    function checkTotalSupplyEqualsOwnerBalance () public {
        console.log("Checking total supply of tokens assigned to the owner");
        Assert.equal(totalSupply(), uint(balanceOf(acc0)), "totalsupply should equals balance of user");
    }


    function checkTransferBetweenAccounts () public {
        console.log("Checking transfer tokens between accounts");
        Assert.ok(msg.sender == acc0, 'caller should be default account i.e. acc0');
        transfer(acc1, 500000000000000000000);
        Assert.equal(uint(balanceOf(acc0)), (500000000000000000000), "Should transfer between account: sender value reduced");
        Assert.equal(uint(balanceOf(acc1)), uint(500000000000000000000), "Should transfer between account: recipient value increased");
    }

    function checkTransferFailedForIsInsufficientBal () public {
        console.log("Checking failure if sender doesn't have enough tokens");
        Assert.ok(msg.sender == acc0, 'caller should be acc0');

        bytes memory methodSign = abi.encodeWithSignature('transfer(address,uint256)', acc2, 200000000000000000000000);
        (bool success,) = address(myTokenToTest).call(methodSign);
        // 'success' will be false if method execution is not successful
        Assert.equal(success, false, 'execution should be successful');
    }


}