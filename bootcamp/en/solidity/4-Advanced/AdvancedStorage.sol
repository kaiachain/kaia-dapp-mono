// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract AdvancedStorage {
    // Declare the address of a vault manager
    address public vaultManager;

    // Declare an error type for unauthorized access
    error OwnableUnauthorizedAccount(address account);

    // Constructor is a function that runs when the contract is initialized
    constructor() {
        // Assign the address of the deployer to the vault manager variable
        vaultManager = msg.sender;
    }

    // Declare the InvestmentVault Struct data type
    struct InvestmentVault {
        uint256 investmentDuration; // Thời gian đầu tư
        int256 returnOnInvestment; // % lãi suất trả về
        bool initialized; // Đã khởi tạo
        address identityCard; // Địa chỉ thẻ thông tin
    }
    // Declare a variable with the InvestmentVault type
    InvestmentVault private investmentVault;

    // This function initializes the investment vault
    function setInitialInvestmentVault(uint256 daysAfter, int256 _returnOnInvestment, address _vaultOwner) public {
        // We check if the initiator is the vaultManager
        if (msg.sender != vaultManager) {
            // This reverts all actions and reverts the transaction
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        // Declare the investment duration
        uint256 _investmentDuration = block.timestamp + daysAfter * 1 days;

        // Create a new identity card for the customer
        CustomerIdentityCard customerIdentityCard = new CustomerIdentityCard(_vaultOwner);
        // Assign the address of the vault owner/customer to the mapping with the vault information
        investmentVault = InvestmentVault({investmentDuration: _investmentDuration, returnOnInvestment: _returnOnInvestment, initialized: true, identityCard: address(customerIdentityCard)});
    }

    // Function to change the return on investment
    function editReturnOnInvestment(int256 _newReturnOnInvestment) public {
        // require keyword works similarly to if and revert above
        require (msg.sender == vaultManager, "Unauthorized Manager");
        // Change the value of the interest rate
        investmentVault.returnOnInvestment = _newReturnOnInvestment;
    }

    // Function to return investmentVault information
    function retrieveInvestmentVault() public view returns (InvestmentVault memory _investmentVault) {
        return investmentVault;
    }

    // Function to return the address of the IdentityCard
    function retrieveCustomerInformation() public view returns (address) {
        return CustomerIdentityCard(investmentVault.identityCard).customer();
    }
}

// Contract that stores the address of the vault owner
contract CustomerIdentityCard {
    //  declares a variable to store the address of the customer
    address public customer;

    // initialize the contract and assign the address of the customer
    constructor(address _customer) {
        customer = _customer;
    }
}

