// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract AdvancedStorage {
    // Khai báo địa chỉ của 1 quản lý két
    address public vaultManager;

    // Đây là khai báo lỗi không được truy cập
    error OwnableUnauthorizedAccount(address account);

    // Constructor là function sẽ chạy ngay khi contract được khởi tạo
    constructor() {
        // Gán địa chỉ của deployer vào biến quản lý két
        vaultManager = msg.sender;
    }

    // Khai báo định dạng dữ liệu InvestmentVault
    struct InvestmentVault {
        uint256 investmentDuration; // Thời gian đầu tư
        int256 returnOnInvestment; // % lãi suất trả về
        bool initialized; // Đã khởi tạo
        address identityCard; // Địa chỉ thẻ thông tin
    }
    // Khai báo 1 biến có định dạng InvestmentVault
    InvestmentVault private investmentVault;

    // Function khởi tạo InvestmentVault
    function setInitialInvestmentVault(uint256 daysAfter, int256 _returnOnInvestment, address _vaultOwner) public {
        // Chúng ta kiểm tra người khởi tạo có phải là vaultManager
        if (msg.sender != vaultManager) {
            // Keyword revert sẽ huỷ toàn bộ các action đã thực hiện và revert/quay ngược lại giao dịch
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        // Khai báo thời gian đầu tư
        uint256 _investmentDuration = block.timestamp + daysAfter * 1 days;

        // Tạo ra 1 identity card mới cho khách hàng
        CustomerIdentityCard customerIdentityCard = new CustomerIdentityCard(_vaultOwner);
        // Gán địa chỉ ví của chủ vault/khách hàng vào mapping với thông tin của vault
        investmentVault = InvestmentVault({investmentDuration: _investmentDuration, returnOnInvestment: _returnOnInvestment, initialized: true, identityCard: address(customerIdentityCard)});
    }

    // Hàm thay đổi lãi suất
    function editReturnOnInvestment(int256 _newReturnOnInvestment) public {
        // keyword require hoạt động tương tự như if và revert ở trên
        require (msg.sender == vaultManager, "Unauthorized Manager");
        // Thay đổi giá trị lãi suất
        investmentVault.returnOnInvestment = _newReturnOnInvestment;
    }

    // Hàm trả về thông tin investmentVault
    function retrieveInvestmentVault() public view returns (InvestmentVault memory _investmentVault) {
        return investmentVault;
    }

    // Hàm trả về address của IdentityCard
    function retrieveCustomerInformation() public view returns (address) {
        return CustomerIdentityCard(investmentVault.identityCard).customer();
    }
}

// Contract khai báo địa chỉ của chủ vault
contract CustomerIdentityCard {
    // khai báo 1 địa chỉ customer
    address public customer;

    // khởi tạo contract và cho vào địa chỉ của customer
    constructor(address _customer) {
        customer = _customer;
    }
}

