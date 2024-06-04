// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";

library SYMath {
    uint256 internal constant ONE = 1e18; // 18 decimal places

    using Math for uint256;

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mulDiv(b, ONE);
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mulDiv(ONE, b);
    }
}
