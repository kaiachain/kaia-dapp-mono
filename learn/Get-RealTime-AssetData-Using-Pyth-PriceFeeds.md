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
PriceConverterPyth Library

```solidity
// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;

import "@pythnetwork/IPyth.sol";
import "@pythnetwork/PythStructs.sol";

/// @title LuckyDraw
/// @author BlockCMD
/// @notice A price converter library that convert tokens on KLAYTN network to USD amount using Pyth Network
library PriceConverterPyth {
    /// @notice Fetch the price of KLAY in USD from Pyth Network price feed
    /// @param pythFeed The address of the price feed contract
    /// @return price The KLAY/USD exchange rate in 18 digit
    function getPrice(
        bytes32 priceFeedId,
        IPyth pythFeed,
        bytes[] calldata priceUpdate
    ) internal returns (uint256 price) {
        // Submit a priceUpdate to the Pyth contract to update the on-chain price.
        // Updating the price requires paying the fee returned by getUpdateFee.
        // WARNING: These lines are required to ensure the getPrice call below succeeds. If you remove them,
        // transactions may fail with "0x19abf40e" error.
        IPyth pyth = pythFeed;
        uint fee = pyth.getUpdateFee(priceUpdate);
        pyth.updatePriceFeeds{value: fee}(priceUpdate);

        // Read the current price from a price feed.
        // Each price feed (e.g., ETH/USD) is identified by a price feed ID.
        // The complete list of feed IDs is available at https://pyth.network/developers/price-feed-ids
        // bytes32 priceFeedId = 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743; // KLAY/USD
        PythStructs.Price memory NewPrice = pyth.getPrice(priceFeedId);
        // PythStructs.Price memory NewPrice = pyth.getPriceUnsafe(feedId);
        price = (uint256(uint64(NewPrice.price) * 10 ** 10));
    }

    /// @notice Convert the any token on the KLAYTN network to USD amount
    /// @param klayAmount The amount of KLAY to convert
    /// @param pythFeed The address of the price feed contract
    /// @return klayAmountInUsd The amount of KLAY in USD
    function getConversionRate(
        uint256 klayAmount,
        bytes32 priceFeedId,
        IPyth pythFeed,
        bytes[] calldata priceUpdate
    ) internal returns (uint256 klayAmountInUsd) {
        uint256 klayPrice = getPrice(priceFeedId, pythFeed, priceUpdate);
        klayAmountInUsd = (klayPrice * klayAmount) / 1e18;
    }
}
```
Overview
The PriceConverterPyth library is a Solidity library designed to convert token amounts on the Klaytn network to USD by leveraging the Pyth Network's price feeds. This utility allows developers to easily fetch real-time price data for KLAY/USD and convert token values into USD within their smart contracts.

Key Features:

Fetch KLAY/USD Price: The library fetches the latest KLAY/USD exchange rate from the Pyth Network.
Convert KLAY to USD: Converts a given amount of KLAY into its equivalent USD value using the fetched exchange rate.
Integration with Pyth Network: The library is integrated with the Pyth Network, a trusted source for real-time, decentralized price feeds.
Prerequisites:

Solidity version ^0.8.19
The Pyth Network’s price feed contracts available on the Klaytn network.
Library Functions
1. 
```solidity
getPrice
function getPrice(
    bytes32 priceFeedId,
    IPyth pythFeed,
    bytes[] calldata priceUpdate
) internal returns (uint256 price)
```

Description: Fetches the current KLAY/USD price from the Pyth Network’s price feed.
Parameters:
priceFeedId: The unique identifier of the price feed (e.g., KLAY/USD feed ID).
pythFeed: The address of the Pyth Network's price feed contract.
priceUpdate: An array of price update data that is used to update the on-chain price feed.
Returns: The current KLAY/USD exchange rate, scaled to 18 decimal places.
Process:
The function first submits a price update to the Pyth contract using the provided priceUpdate data, paying the necessary fee.
It then retrieves the latest KLAY/USD price using the priceFeedId and returns the price scaled to 18 decimal places.
Important Notes:
Ensure the price update is submitted before fetching the price. Failing to do so might result in outdated or incorrect data, leading to transaction failures.

2. 
```solidity
getConversionRate
function getConversionRate(
    uint256 klayAmount,
    bytes32 priceFeedId,
    IPyth pythFeed,
    bytes[] calldata priceUpdate
) internal returns (uint256 klayAmountInUsd)
```

Description: Converts a specified amount of KLAY into its USD equivalent using the latest price data from the Pyth Network.
Parameters:
klayAmount: The amount of KLAY to be converted to USD.
priceFeedId: The unique identifier of the price feed (e.g., KLAY/USD feed ID).
pythFeed: The address of the Pyth Network's price feed contract.
priceUpdate: An array of price update data used to update the on-chain price feed.
Returns: The equivalent USD value of the given KLAY amount.
Process:
The function first calls getPrice() to fetch the current KLAY/USD exchange rate.
It then calculates the USD equivalent of the provided KLAY amount by multiplying the exchange rate with klayAmount and dividing by 1e18 (to account for the scaling factor).

Example Usage

```solidity
import "./PriceConverterPyth.sol";
contract MyContract {
    using PriceConverterPyth for uint256;
    
    IPyth public pythFeed;
    bytes32 public priceFeedId;
    
    constructor(IPyth _pythFeed, bytes32 _priceFeedId) {
        pythFeed = _pythFeed;
        priceFeedId = _priceFeedId;
    }
    
    function convertKlayToUsd(uint256 klayAmount, bytes[] calldata priceUpdate) external returns (uint256) {
        return klayAmount.getConversionRate(priceFeedId, pythFeed, priceUpdate);
    }
}
```

The PriceConverterPyth library provides a simple and effective way to interact with the Pyth Network's price feeds on the Klaytn blockchain. By using this library, developers can easily fetch real-time KLAY/USD prices and convert token amounts into USD, enabling more dynamic and responsive smart contract applications.

CreatePriceUpdateData Solidity Contract
Overview
This project contains the CreatePriceUpdateData contract, a utility for generating price feed update data using the Pyth Network's mock implementation (MockPyth). The contract is designed to create and validate price data updates on test networks, leveraging configuration data provided by a separate NetworkConfig contract.

The key purpose of this contract is to generate and simulate price feed updates, which can be used to test and develop applications that rely on Pyth Network price feeds.

Key Components
Imports
forge-std/Script.sol: Used to create and execute scripts with Foundry, a popular Ethereum development framework.
MockPyth.sol: A mock implementation of the Pyth Network’s on-chain components, used for testing purposes.
PythStructs.sol: Contains the struct definitions used by Pyth Network contracts.
NetworkConfig.s.sol: Script that manages network-specific configuration, including price feed IDs and mock Pyth addresses.
Constants.sol: Contains constant values used throughout the contract.
Errors
CreatePriceUpdateData__InvalidPriceFeedId: Thrown when the price feed ID provided is invalid or empty.
CreatePriceUpdateData__PriceFeedIdDoesNotExist: Thrown when the specified price feed ID does not exist in the mock Pyth contract.
CreatePriceUpdateData__InvalidMockAddress: Thrown when the mock Pyth address is invalid (e.g., an address of 0x0).
CreatePriceUpdateData Contract

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockPyth.sol";
import "@pythnetwork/PythStructs.sol";
import "../script/NetworkConfig.s.sol";
import "../src/Constants.sol";

error CreatePriceUpdateData__InvalidPriceFeedId();
error CreatePriceUpdateData__PriceFeedIdDoesNotExist();
error CreatePriceUpdateData__InvalidMockAddress();

contract CreatePriceUpdateData is Constants, Script {
    struct PriceData {
        bytes32 id;
        int64 price;
        uint64 conf;
        int32 expo;
        int64 emaPrice;
        uint64 emaConf;
        uint64 publishTime;
    }

    function run() public returns (bytes memory) {
        return createPriceUpdateDataConfig();
    }

    function createPriceUpdateDataConfig()
        public
        returns (bytes memory priceUpdateData)
    {
        NetworkConfig networkConfig = new NetworkConfig();
        bytes32 id = networkConfig.getConfig().priceFeedId;
        address pythAddress = networkConfig.getConfig().pythFeedAddress;

        priceUpdateData = createPriceData(id, pythAddress);
    }

    function createPriceData(
        bytes32 id,
        address pythAddress
    ) public returns (bytes memory priceFeedUpdateData) {
        if (id == hex"") {
            revert CreatePriceUpdateData__InvalidPriceFeedId();
        }

        if (pythAddress == address(0)) {
            revert CreatePriceUpdateData__InvalidMockAddress();
        }

        MockPyth mockPyth = MockPyth(pythAddress);
        console.log(pythAddress);

        if (!mockPyth.priceFeedExists(id)) {
            revert CreatePriceUpdateData__PriceFeedIdDoesNotExist();
        }

        PriceData memory priceData = setPriceData(id);

        vm.startBroadcast();
        priceFeedUpdateData = mockPyth.createPriceFeedUpdateData(
            priceData.id,
            priceData.price,
            priceData.conf,
            priceData.expo,
            priceData.emaPrice,
            priceData.emaConf,
            priceData.publishTime
        );
        vm.stopBroadcast();

        /** Test MockPyth works */
        uint validTime = mockPyth.getValidTimePeriod();
        console.log(validTime);

        // PythStructs.PriceFeed memory priceFeed = mockPyth.queryPriceFeed(id);
        // console.log(priceFeed);
    }

    function setPriceData(bytes32 id) public view returns (PriceData memory) {
        PriceData memory priceData = PriceData({
            id: id,
            price: PRICE,
            conf: CONF,
            expo: EXPO,
            emaPrice: EMA_PRICE,
            emaConf: EMA_CONF,
            publishTime: PUBLISH_TIME
        });

        return priceData;
    }
}
```

This contract contains the following key functions:

run(): This is the main entry point for the script. It calls createPriceUpdateDataConfig() to generate the price update data.
createPriceUpdateDataConfig(): This function fetches the price feed ID and mock Pyth address from the NetworkConfig contract and passes them to createPriceData() to generate the price update data.
createPriceData(): This function:
Validates the provided price feed ID and mock Pyth address.
Checks if the specified price feed ID exists in the mock Pyth contract.
Uses the validated data to generate price feed update data using the MockPyth.createPriceFeedUpdateData() function.
Optionally tests the mock Pyth functionality, such as retrieving the valid time period.
4. setPriceData(): This function creates and returns a PriceData struct populated with the price data constants defined in the Constants contract.

PriceData Struct
The PriceData struct represents the price data required to update a price feed:

id: The unique identifier of the price feed.
price: The current price of the asset.
conf: The confidence interval for the price.
expo: The exponent used to scale the price (e.g., -8 means the price is in 10^-8 units).
emaPrice: The exponentially weighted moving average of the price.
emaConf: The confidence interval for the EMA price.
publishTime: The timestamp when the price data was published.

Constants:

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

abstract contract Constants {
    uint public VALID_TIME_PERIOD = block.timestamp + 2 days;
    uint public constant SINGLE_UPDATE_FEE_IN_WEI = 0.01 ether;

    uint256 public constant TESTNET_CONFIG = 1001;
    uint256 public constant MAINNET_CONFIG = 8217;
    uint256 public constant ANVIL_CONFIG = 31337;

    int64 public constant PRICE = 100;
    uint64 public constant CONF = 500;
    int32 public constant EXPO = -8;
    int64 public constant EMA_PRICE = 100;
    uint64 public constant EMA_CONF = 400;
    uint64 public PUBLISH_TIME = uint64(block.timestamp);
}
```

VALID_TIME_PERIOD: The period within which the price update is valid, set to 2 days from the current block timestamp.
SINGLE_UPDATE_FEE_IN_WEI: The fee for a single price update, set to 0.01 ETH.
Price Data Constants: Various constants related to the price data, such as PRICE, CONF, EXPO, EMA_PRICE, EMA_CONF, and PUBLISH_TIME.

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
curl https://hermes.pyth.network/api/latest_vaas?ids[]=0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743
```

Once you have the priceUpdateData, you can use Foundry’s cast command-line tool to interact with the smart contract and call the getLatestPrice(bytes[]) function to fetch the latest price of KLAY.

To call the getLatestPrice(bytes[]) function of the smart contract, run the following command, replacing <DEPLOYED_ADDRESS> with the address of your deployed contract, and <PRICE_UPDATE_DATA> with the priceUpdateData returned by the Hermes endpoint:

```bash
cast call <DEPLOYED_ADDRESS> --rpc-url $TESTNET_RPC "getLatestPrice(bytes[])" <PRICE_UPDATE_DATA>
```

## Conclusion
You’ve successfully deployed a smart contract that uses Pyth Network’s price feeds to validate funding amounts in USD. You’ve also learned how to generate mock price update data for testing. This powerful combination of tools allows for more dynamic and responsive smart contract development.