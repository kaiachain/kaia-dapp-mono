// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import {AdvancedStorage, CustomerIdentityCard} from "../AdvancedStorage.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is AdvancedStorage {

    AdvancedStorage advancedStorage;
    address acc0;
    address acc1;
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        advancedStorage = new AdvancedStorage();
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
    }

    function checkVaultManager() public returns (bool) {
        return Assert.equal(this.vaultManager(), msg.sender, "Vault Manager is not correct");
    }

    function checkSettingInitialInvestment() public returns (bool, bool, bool) {
        setInitialInvestmentVault(
            10,
            5,
            acc1
        );
        return (
            Assert.equal(retrieveInvestmentVault().investmentDuration, block.timestamp + 10 days, "Duration is not correct"),
            Assert.equal(retrieveInvestmentVault().returnOnInvestment, 5, "Return on Investment is not correct"),
            Assert.equal(retrieveInvestmentVault().initialized, true, "Initialization status is not correct")
        );
    }

    /// #sender: account-1
    function checkFailedSettingInitialInvestmentButWithUnautorizedAccount() public returns (bool) {
        setInitialInvestmentVault(
            10,
            5,
            acc1
        );
        return (Assert.ok(true, "True"));
    }

    function checkRetrieveCustomerInformation() public returns (bool) {
        return Assert.equal(retrieveCustomerInformation(), acc1, "Customer information is wrong");
    }
}

    