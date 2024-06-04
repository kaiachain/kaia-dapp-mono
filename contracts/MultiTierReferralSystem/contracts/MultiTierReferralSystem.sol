// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MultiTierReferralSystem is ReentrancyGuard, ERC721Enumerable {
    IERC20 private tokenUSDC;

    // Can set it according wishes up to 10 level
    uint256[] private shareValue = [
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6, // $10
        10e6 // $10
    ];
    uint256 public lastUplineTokenId;

    mapping(uint256 => uint256) public lineTier;
    mapping(uint256 => uint256) public receivedUSDC;

    event Registration(uint256 indexed newTokenId, uint256 indexed uplineTokenId, uint256 indexed timestamp);

    constructor(address _addressUSDC, address _defaultUplineAddress) ERC721("Multi-Tier Referral System", "MTRS") {
        tokenUSDC = IERC20(_addressUSDC);
        for (uint256 i = shareValue.length; i > 0; i--) {
            lineTier[i] = i - 1;
            _safeMint(_defaultUplineAddress, i);
        }
        lastUplineTokenId = shareValue.length;
    }

    function registration(uint256 _uplineTokenId, uint256 _newTokenId) external nonReentrant {
        uint256 lengthShareValue = shareValue.length;
        require(_newTokenId > lengthShareValue, "Set new tokenId");
        require(_uplineTokenId == 0 || _requireOwned(_uplineTokenId) != address(0), "Upline tokenId not already minted");
        address who = _msgSender();

        uint256 uplineTokenId = _uplineTokenId > lengthShareValue ? _uplineTokenId : lastUplineTokenId;
        lineTier[_newTokenId] = uplineTokenId;

        uint256 profit;
        uint256 currentUplineTokenId = uplineTokenId;
        for (uint256 i = 0; i < lengthShareValue; i++) {
            profit = shareValue[i];
            receivedUSDC[currentUplineTokenId] += profit;
            tokenUSDC.transferFrom(who, ownerOf(currentUplineTokenId), profit);
            currentUplineTokenId = lineTier[currentUplineTokenId];
        }

        _safeMint(who, _newTokenId);
        emit Registration(_newTokenId, uplineTokenId, block.timestamp);
    }

    function rangeTokenIds(address _who, uint256 _startIndex, uint256 _stopIndex) public view returns (uint256[] memory) {
        uint256 lengthOwned = _stopIndex - _startIndex;
        uint256[] memory ownedTokenIds = new uint256[](lengthOwned);
        uint256 index = 0;
        for (uint i = _startIndex; i < (_stopIndex + 1); i++) {
            ownedTokenIds[index] = tokenOfOwnerByIndex(_who, i);
            index++;
        }
        return ownedTokenIds;
    }

    function rangeInfo(address _who, uint256 _startIndex, uint256 _stopIndex) external view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory ownedTokenIds = rangeTokenIds(_who, _startIndex, _stopIndex);
        uint256[] memory profitUSDCByTokenId = new uint256[](ownedTokenIds.length);
        for (uint i = 0; i < ownedTokenIds.length; i++) {
            profitUSDCByTokenId[i] = receivedUSDC[ownedTokenIds[i]];
        }
        return (ownedTokenIds, profitUSDCByTokenId);
    }

    function allTokenIds(address _who) public view returns (uint256[] memory) {
        uint256 lengthOwned = balanceOf(_who);
        uint256[] memory ownedTokenIds = new uint256[](lengthOwned);
        for (uint i = 0; i < lengthOwned; i++) {
            ownedTokenIds[i] = tokenOfOwnerByIndex(_who, i);
        }
        return ownedTokenIds;
    }

    function allInfo(address _who) external view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory ownedTokenIds = allTokenIds(_who);
        uint256[] memory profitUSDCByTokenId = new uint256[](ownedTokenIds.length);
        for (uint i = 0; i < ownedTokenIds.length; i++) {
            profitUSDCByTokenId[i] = receivedUSDC[ownedTokenIds[i]];
        }
        return (ownedTokenIds, profitUSDCByTokenId);
    }
}