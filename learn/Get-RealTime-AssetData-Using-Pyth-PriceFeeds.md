# Integrating Pyth Network's Real-Time Price Feeds in Solidity

In this tutorial, we will explore how to integrate Pyth Network’s real-time price feeds into a smart contract using Solidity. You'll learn how to set up a project, install the necessary dependencies, write and deploy the contract, and generate price update data using a mock contract or from the hermes api.

By the end of this tutorial, you’ll be able to:

1. Set up a smart contract project using Foundry.
2. Install and integrate Pyth smart contracts.
3. Utilize Pyth price feeds in your smart contract.
4. Deploy and interact with the smart contract on the Kaia chain network.
5. Generate and use mock price update data for testing.

## Table of Contents
- [Integrating Pyth Network's Real-Time Price Feeds in Solidity](#integrating-pyth-networks-real-time-price-feeds-in-solidity)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [What is Pyth Network?](#what-is-pyth-network)
  - [Setting Up the Project](#setting-up-the-project)
  - [Writing the Smart Contract](#writing-the-smart-contract)
  - [Understanding the Contract](#understanding-the-contract)
  - [Deploying the Contract](#deploying-the-contract)
  - [Generating Price Update Data:](#generating-price-update-data)
  - [Interaction from the Hermes API](#interaction-from-the-hermes-api)
  - [Conclusion](#conclusion)

## Prerequisites

Before diving into the code, ensure you have the following:

- **Foundry**: A popular Ethereum development framework.
- **Solidity Basics**: A basic understanding of writing smart contracts in Solidity.

## What is Pyth Network?

Pyth Network is designed for ultra-low latency and real-time data, making it ideal for financial applications requiring sub-second updates. It provides data for a range of traditional and DeFi assets.

## Setting Up the Project

To begin, create a new Foundry project by running the following commands:

```bash
mkdir myproject
cd myproject
forge init
```
This sets up the basic project structure. Next, install the Pyth smart contracts as a dependency:

```bash
forge install pyth-network/pyth-sdk-solidity@v2.2.0 --no-git --no-commit
```

Update your foundry.toml file with the following line to include the Pyth contracts:

```toml
remappings = ['@pythnetwork/pyth-sdk-solidity/=lib/pyth-sdk-solidity']
```
## Writing the Smart Contract
We’ll now create a smart contract named FundMe, which utilizes Pyth price feeds to ensure that all funds sent to the contract meet a minimum USD value requirement.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./PriceConverterPyth.sol";
import "@pythnetwork/IPyth.sol";
import "@pythnetwork/PythStructs.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverterPyth for uint256;
    
    address private immutable i_owner;
    bytes32 public immutable i_feedId;
    uint256 public constant MINIMUM_USD = 2 * 1e18;
    address[] private Funders;
    mapping(address => uint256) private addressToAmountFunded;
    IPyth public pyth;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress, bytes32 priceFeedId) {
        i_owner = msg.sender;
        pyth = IPyth(priceFeedAddress);
        i_feedId = priceFeedId;
    }

    function fund(bytes[] calldata priceUpdate) public payable {
        require(
            msg.value.getConversionRate(i_feedId, pyth, priceUpdate) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        Funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < Funders.length; funderIndex++) {
            address funder = Funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        Funders = new address ;
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
}
```

## Understanding the Contract

1. PriceConverterPyth Library: This library is used to fetch the latest KLAY/USD price and convert KLAY amounts to USD. The `getConversionRate` function is essential for ensuring that users fund the contract with a minimum USD value.

2. FundMe Contract: This contract allows users to fund it with KLAY, but only if the KLAY amount meets the minimum USD requirement. The `fund` function utilizes the `getConversionRate` method to convert the sent KLAY amount to USD and checks it against the minimum value.

3. Only Owner Modifier: The contract owner can withdraw the funds, ensuring security and control.

## Deploying the Contract

Set up your deployment environment:

1. Import Your Wallet:

```bash
cast wallet import deployer --interactive
```

2. Set Up Environment Variables:

Create an `.env` file with the following content:

```bash
KAIA_TESTNET_RPC=https://api.baobab.klaytn.net:8651
```
3. Deploy the Contract:

Deploy the contract to testnet rpc by running:

```bash
 forge create ./src/FundMe.sol:FundMe - rpc-url $KAIA_TESTNET_RPC - account deployer
 ```

## Generating Price Update Data:

To test the contract, you need to generate price update data. We’ll use a mock Pyth contract to simulate this:

```solidity
import "@pythnetwork/MockPyth.sol";
import "./CreatePriceUpdateData.sol";

contract TestPythPriceFeed {
    MockPyth public mockPyth;

    constructor(address mockPythAddress) {
        mockPyth = MockPyth(mockPythAddress);
    }

    function updatePriceFeed(bytes32 priceFeedId, int64 price, uint64 publishTime) external {
        mockPyth.createPriceFeedUpdateData(priceFeedId, price, publishTime);
    }
}
```
This contract allows you to create price updates for testing by interacting with the MockPyth contract.

For an advanced test integration using the MockPyth contract, [check the code here](https://github.com/PaulElisha/foundryTemplate-PythPriceFeed/)

## Interaction from the Hermes API
The getLatestPrice(bytes[]) function of the deployed contract takes a priceUpdateData argument that is used to get the latest price. This data can be fetched using the Hermes web service. Hermes allows users to easily query for recent price updates via a REST API.

Make a curl request to fetch the priceUpdateData using the priceId 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743:

```bash
curl https://hermes.pyth.network/api/latest_vaas?ids[]=0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace
```

Once you have the priceUpdateData, you can use Foundry’s cast command-line tool to interact with the smart contract and call the getLatestPrice(bytes[]) function to fetch the latest price of KLAY.

To call the getLatestPrice(bytes[]) function of the smart contract, run the following command, replacing <DEPLOYED_ADDRESS> with the address of your deployed contract, and <PRICE_UPDATE_DATA> with the priceUpdateData returned by the Hermes endpoint:

```bash
cast call <DEPLOYED_ADDRESS> --rpc-url $BASE_SEPOLIA_RPC "getLatestPrice(bytes[])" <PRICE_UPDATE_DATA>
```

## Conclusion
You’ve successfully deployed a smart contract that uses Pyth Network’s price feeds to validate funding amounts in USD. You’ve also learned how to generate mock price update data for testing. This powerful combination of tools allows for more dynamic and responsive smart contract development.