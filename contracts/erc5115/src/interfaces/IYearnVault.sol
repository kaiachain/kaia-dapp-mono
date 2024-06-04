// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.20;

interface IYearnVault {
    function deposit(uint256 amount) external returns (uint256);

    function withdraw(uint256 maxShares) external returns (uint256);

    function pricePerShare() external view returns (uint256);
}