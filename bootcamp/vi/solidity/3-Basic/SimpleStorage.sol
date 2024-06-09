// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract SimpleStorage {

    // Khai báo các biến liên quan đến người sáng lập
    string public maintainerName = "zxstim";
    // Khai báo phiên bản của contract
    uint8 public version = 1;
    // Địa chỉ nhận quyên góp
    address public donationAddress = 0xe3d25540BA6CED36a0ED5ce899b99B5963f43d3F;

    // Khai báo cấu trúc Person
    struct Person {
        string name; // Tên
        uint8 age; // Tuổi
        bool overEighteen; // Đủ 18 tuổi
        address uuid; // UUID
        uint256 assetValue; // Giá trị tài sản
        int256 debtValue; // Giá trị nợ
    }

    Person[] private listOfPeople; // syntax này có nghĩa là tạo một Array chứa các Person tên là listOfPeople
    
    mapping(address => Person) uuidToPerson; // syntax này có nghĩa là tạo một mapping từ address sang Person tên là uuidToPerson

    // function lưu thông tin của 1 person mới với các thông tin như name, age, overEighteen, assetValue, debtValue
    function storePerson(string memory _name, uint8 _age, bool _overEighteen, uint256 _assetValue, int256 _debtValue) public returns (Person memory person) {
        _assetValue *= 1e18; // Chuyển đổi giá trị tài sản sang đơn vị wei
        _debtValue *= 1e18; // Chuyển đổi giá trị nợ sang đơn vị wei
        // Thêm thông tin của person mới vào danh sách listOfPeople
        listOfPeople.push(Person({name: _name, age: _age, overEighteen: _overEighteen, uuid: msg.sender, assetValue: _assetValue, debtValue: _debtValue}));
        // Thêm thông tin của person mới vào mapping uuidToPerson
        uuidToPerson[msg.sender] = Person({name: _name, age: _age, overEighteen: _overEighteen, uuid: msg.sender, assetValue: _assetValue, debtValue: _debtValue});
        return Person({name: _name, age: _age, overEighteen: _overEighteen, uuid: msg.sender, assetValue: _assetValue, debtValue: _debtValue});
    }

    // function lấy thông tin của 1 person dựa trên địa chỉ
    function retrievePerson(address _address) public view returns (Person memory person) {
        return uuidToPerson[_address];
    }
}