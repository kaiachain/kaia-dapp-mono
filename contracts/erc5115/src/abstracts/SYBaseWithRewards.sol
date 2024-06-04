// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import "../interfaces/IStandardizedYield.sol";
import "./RewardManager.sol";
import "./SYBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract SCYBaseWithRewards is SYBase, RewardManager {
    using Math for uint256;

    constructor(string memory _name, string memory _symbol, address _yieldToken) SYBase(_name, _symbol, yieldToken) {}

    /*///////////////////////////////////////////////////////////////
                               REWARDS-RELATED
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev See {IStandardizedYield-claimRewards}
     */
    function claimRewards(address user) external virtual override returns (uint256[] memory rewardAmounts) {
        _updateAndDistributeReward(user);
        rewardAmounts = _doTransferOutRewards(user, user);

        emit ClaimRewards(user, _getRewardTokens(), rewardAmounts);
    }

    /**
     * @dev See {IStandardizedYield-getRewardTokens}
     */
    function getRewardTokens() external view virtual override returns (address[] memory rewardTokens) {
        rewardTokens = _getRewardTokens();
    }

    /**
     * @dev See {IStandardizedYield-accruedRewards}
     */
    function accruedRewards(address user) external view virtual override returns (uint256[] memory rewardAmounts) {
        address[] memory rewardTokens = _getRewardTokens();
        rewardAmounts = new uint256[](rewardTokens.length);
        for (uint256 i = 0; i < rewardTokens.length;) {
            rewardAmounts[i] = userRewardAccrued[user][rewardTokens[i]];
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice returns the total number of reward shares
     * @dev this is simply the total supply of shares, as rewards shares are equivalent to SCY shares
     */
    function _rewardSharesTotal() internal virtual override returns (uint256) {
        return totalSupply();
    }

    /**
     * @notice returns the reward shares of (`user`)
     * @dev this is simply the SCY balance of (`user`), as rewards shares are equivalent to SCY shares
     */
    function _rewardSharesUser(address user) internal virtual override returns (uint256) {
        return balanceOf(user);
    }

    /*///////////////////////////////////////////////////////////////
                            TRANSFER HOOKS
    //////////////////////////////////////////////////////////////*/
    function _beforeTokenTransfer(address from, address to, uint256 /*amount*/ ) internal virtual {
        _updateRewardIndex();
        if (from != address(0) && from != address(this)) _distributeUserReward(from);
        if (to != address(0) && to != address(this)) _distributeUserReward(to);
    }
}
