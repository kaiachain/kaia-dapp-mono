// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../SimpleStorage.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is SimpleStorage {
    
    SimpleStorage simpleStorage;
    address acc0;
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        simpleStorage = new SimpleStorage();
        acc0 = TestsAccounts.getAccount(0);
    }

    function checkMaintainerName() public returns (bool) {
        return Assert.equal(simpleStorage.maintainerName(), "zxstim", "Maintainer name is not correct");
    }

    function checkVersion() public returns (bool) {
        return Assert.equal(simpleStorage.version(), 1, "Version is not 1");
    }

    function checkDonationAddress() public returns (bool) {
        return Assert.equal(simpleStorage.donationAddress(), 0xe3d25540BA6CED36a0ED5ce899b99B5963f43d3F, "Donation address is not correct");
    }

    /// #sender: account-0
    function checkStoredPerson() public returns (bool, bool, bool, bool, bool, bool) {
        Person memory person = storePerson("victor",30,true,10,2);
        return (
            Assert.equal(person.name, "victor", "Name is not correct"), 
            Assert.equal(person.age, 30, "Age is not correct"),
            Assert.equal(person.overEighteen, true, "overEighteen status is not correct"),
            Assert.equal(person.uuid, msg.sender, "Address is not correct"),
            Assert.equal(person.assetValue, 10e18, "Asset value is not correct"),
            Assert.equal(person.debtValue, 2e18, "Debt value is not correct")
            );
    }

    /// #sender: account-0
    function checkRetrivePersonWithAddress() public returns (bool, bool, bool, bool, bool, bool) {
        Assert.ok(msg.sender == acc0, "caller should be default account i.e. acc0");
        storePerson("victor",30,true,10,2);
        return (
            Assert.equal(retrievePerson(msg.sender).name, "victor", "Name is not correct"),
            Assert.equal(retrievePerson(msg.sender).age, 30, "Age is not correct"),
            Assert.equal(retrievePerson(msg.sender).overEighteen, true, "overEighteen status is not correct"),
            Assert.equal(retrievePerson(msg.sender).uuid, msg.sender, "Address is not correct"),
            Assert.equal(retrievePerson(msg.sender).assetValue, 10e18, "Asset value is not correct"),
            Assert.equal(retrievePerson(msg.sender).debtValue, 2e18, "Debt value is not correct")
            );
    }
}
    