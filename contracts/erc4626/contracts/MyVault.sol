// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyVault is ERC4626 {
    constructor(address asset) ERC4626(IERC20(asset)) ERC20("myVault", "MYVAULT") {
    }
}