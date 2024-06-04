// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@klaytn/contracts/token/ERC20/IERC20.sol";
import "./Contribute.sol";


contract ContributionSystemFactory {
    // Structure to store system information
    struct SystemInfo {
        address systemAddress;  // Address of the ContributionSystem contract
        address creator;        // Address of the creator
    }

    mapping(address => SystemInfo[]) public systemsByCreator;  // Mapping of the creator's address to their ContributionSystem contracts
    address[] public deployedSystems;                           // Array to store addresses of all deployed ContributionSystem contracts

    event ContributionSystemCreated(address indexed newSystem, address indexed creator);

    // Create a new instance of the ContributionSystem contract
    function createContributionSystem(
        address coordinator,
        bytes32 _keyHash,
        uint256 _fee,
        uint _dayRange,
        uint _expectedNumber,
        uint _contributionAmount,
        address _tokenAddress
    ) external {
        ContributionSystem newSystem = new ContributionSystem(
            coordinator,
            _keyHash,
            _fee,
            _dayRange,
            _expectedNumber,
            _contributionAmount,
            _tokenAddress
        );
        deployedSystems.push(address(newSystem));
        emit ContributionSystemCreated(address(newSystem), msg.sender);

        SystemInfo memory info;
        info.systemAddress = address(newSystem);
        info.creator = msg.sender;
        systemsByCreator[msg.sender].push(info);
    }

    // Returns the list of deployed ContributionSystem contracts
    function getDeployedSystems() external view returns (address[] memory) {
        return deployedSystems;
    }

    // Returns the list of ContributionSystem contracts deployed by a specific creator
    function getSystemsByCreator(address _creator) external view returns (SystemInfo[] memory) {
        return systemsByCreator[_creator];
    }
}
