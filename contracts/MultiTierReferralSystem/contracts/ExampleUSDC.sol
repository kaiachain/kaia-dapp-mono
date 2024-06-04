// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ExampleUSDC is ERC20("USDC", "USDC") {
    constructor() {
        _mint(_msgSender(), 1000000000e6);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}