// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract SimpleStorage {

    // Declare a variable to store the name of the maintainer
    string public maintainerName = "zxstim";
    // Declare the version of the contract
    uint8 public version = 1;
    // Declare an address to receive donation
    address public donationAddress = 0xe3d25540BA6CED36a0ED5ce899b99B5963f43d3F;

    // Declare a Person type to store information of a person
    struct Person {
        string name; // name    
        uint8 age; // age
        bool overEighteen; // Over eighteen?
        address uuid; // UUID
        uint256 assetValue; // asset value
        int256 debtValue; // debt value
    }

    Person[] private listOfPeople; // this syntax means creating an array to store Person named listOfPeople
    
    mapping(address => Person) uuidToPerson; // this syntax means creating a mapping from address to Person named uuidToPerson

    //  this function will store the information of a new person with name, age, overEighteen, assetValue, debtValue
    function storePerson(string memory _name, uint8 _age, bool _overEighteen, uint256 _assetValue, int256 _debtValue) public returns (Person memory person) {
        _assetValue *= 1e18; // Convert asset value to wei unit
        _debtValue *= 1e18; // Convert debt value to wei unit
        // Add information of the new person to the listOfPeople array
        listOfPeople.push(Person({name: _name, age: _age, overEighteen: _overEighteen, uuid: msg.sender, assetValue: _assetValue, debtValue: _debtValue}));
        // Add information of the new person to the uuidToPerson mapping
        uuidToPerson[msg.sender] = Person({name: _name, age: _age, overEighteen: _overEighteen, uuid: msg.sender, assetValue: _assetValue, debtValue: _debtValue});
        return Person({name: _name, age: _age, overEighteen: _overEighteen, uuid: msg.sender, assetValue: _assetValue, debtValue: _debtValue});
    }

    // this function will retrieve the information of a person based on the address
    function retrievePerson(address _address) public view returns (Person memory person) {
        return uuidToPerson[_address];
    }
}