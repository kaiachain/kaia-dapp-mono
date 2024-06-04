// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(address _addr) ERC20("MyToken", "MTK") {
        _mint(_addr, 1000 * 10 ** decimals());
    }
}