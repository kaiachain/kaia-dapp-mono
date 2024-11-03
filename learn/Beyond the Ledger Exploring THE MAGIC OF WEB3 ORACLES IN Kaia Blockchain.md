
# Beyond the Ledger: Exploring the Magic of Web3 Oracles in Kaia Blockchain

The digital messengers that enable smart contracts to access real-world data, opening up new possibilities for decentralized applications are Oracles. Oracles play a crucial role as intermediaries between the deterministic blockchain and the dynamic external world, by bridging the gap between on-chain and off-chain information. Oracles empower blockchains to react to current events, not just predetermined rules. From cryptocurrency prices to weather updates, oracles bring the real world into the blockchain ecosystem.

In this article, we will explore how oracles function, their types (pull-based and push-based), and how they integrate with the Kaia blockchain. We will examine practical examples of fetching real-time data and generating random numbers, showcasing the potential of these innovative tools in shaping the future of decentralized applications.

## Prerequisites

- Basic knowledge of blockchain technology and smart contracts
- Understanding of the concept of oracles in blockchain systems
- Familiarity with Solidity programming language
- Access to a Kaia Chain development environment
- Installation of Foundry, a tool for Ethereum development
- Git and basic command line skills
- Knowledge of web3.js or ethers.js libraries for interacting with blockchains
- Understanding of decentralized finance (DeFi) concepts
- Familiarity with the Kaia Chain architecture and tools
- Basic knowledge of cryptocurrency markets and price feeds.

## What is Oracle?

An oracle is any element, gadget, or system that interfaces a deterministic blockchain network with offline, external information. This link enables smart contracts to access, verify, and utilize real-world data, bridging the gap between the on-chain economy and the real world.

### Definition breakdown of Oracle:
- **Deterministic blockchain networks:** Blockchain platforms like Ethereum and Bitcoin operate deterministically, which means the same input always produces the same outputs. This ensures consistency and predictability across the network.
- **Offline information:** Data sources outside the blockchain ecosystem, such as sports results, election outcomes, IoT sensor readings, weather APIs, and stock prices.
- **Interfacing:** Oracles act as communication layers, translating external data into a format compatible with blockchain-based smart contracts.
- **Element, gadget, or system:** Oracles can take various forms, including software APIs, hardware devices, or human-operated services.

### Oracle services employ two approaches.

1. **Pull-based Oracles:** It involves smart contracts actively requesting or retrieving data from the database consistently. The Oracle node listens for these requests and fetches the required data on demand.

#### How It Works:
- A smart contract initiates a data request
- The Oracle node detects this request
- The node queries the specified external data source
- Data is processed and validated
- The oracle returns the data to the smart contract

#### Example:

```solidity
contract PullBasedExample {
    address public oracle;
    uint256 public ethereumPrice;    
  
  function requestEthereumPrice() external {
        // Request price update from Oracle
        OracleInterface(oracle).requestData("ETH/USD");
    }
        function fulfillRequest(uint256 price) external {
        require(msg.sender == oracle, "Only oracle can fulfill");
        ethereumPrice = price;
    }
}
```

2. **Push-based Oracles:** Automatically send data to smart contracts when certain conditions are met, instead of waiting for the smart contract to ask for it.

#### How It Works:
- Oracle nodes continuously monitor data sources
- When specific conditions are met the oracle automatically pushes data to relevant smart contracts
- Smart contracts process the received data.

#### Example:

```solidity
contract PushBasedExample {
    address public oracle;
    uint256 public ethereumPrice;
    
    function updatePrice(uint256 newPrice) external {
        require(msg.sender == oracle, "Only oracle can update");
        ethereumPrice = newPrice;
    }
}
```

### Differences between Pull-based and Push-based Oracles
1. Pull oracles support a wide selection of price feeds, while push oracles have a more limited selection.
2. Push oracle price feed updates at a fixed frequency, typically between every 10 minutes to 1 hour, whereas pull oracles can update at a much higher frequency.
3. Pull-based Oracle requires a contract to initiate the request, while Push-based Oracle initiates the data transfer.
4. Pull oracles support more blockchains, whereas Push oracles typically support fewer due to gas costs.

### Oracle Providers
#### Pull-Based Providers:
- Chainlink (supports both pull and push)
- Band Protocol
- API3
- Tellor
- UMA Protocol
- Pyth Network

#### Push-Based Providers:
- Chainlink (Keepers and Data Feeds)
- Razor Network
- Witnet
- DIA

# Oracle Architecture: Chainlink

Chainlink’s architecture is built around two main components: on-chain and off-chain elements. These components work together to securely deliver real-world data to smart contracts on the blockchain through a unique consensus mechanism. This setup allows multiple nodes to verify and reach a consensus on input for smart contracts, which can be repeatedly retrieved to ensure continuous accuracy and integrity. The entire system is engineered to securely feed data through its consensus mechanism, ensuring data validity and security at every step.

## 1. On-Chain Components

On-chain components are essential for meeting the blockchain’s native validation needs. These components consist primarily of oracle contracts, typically based on the Ethereum blockchain, which act as intermediaries to process off-chain data requests and return results in a blockchain-compatible format.

### Oracle Contracts

These smart contracts facilitate the translation of off-chain data requests into on-chain data flows. Deployed directly on the blockchain, these contracts are designed to receive data requests from users and manage the request lifecycle by distributing it to nodes, monitoring node responses, and handling final data aggregation. There are several types of oracle contracts in Chainlink’s ecosystem:

1. **Requesting Contracts**: Initiate data requests by interacting with oracle contracts, specifying data types and node requirements.
   
2. **Aggregator Contracts**: Aggregate responses from multiple nodes to derive a single, reliable result. This aggregation employs consensus methods, such as median calculations, to discard outliers and prevent any single node from influencing the final outcome.
   
3. **Service Level Agreements (SLAs)**: Define parameters for data retrieval, including node performance expectations, deviation thresholds, and penalties for malicious behavior. SLAs help maintain data reliability by enforcing standards for node performance.

4. **LINK Token**: The LINK token is integral to Chainlink’s on-chain processes. It serves as a payment mechanism for node operators and functions as a staking asset, incentivizing accurate, reliable data submissions.

## 2. Off-Chain Components

Off-chain components in Chainlink are responsible for handling external data sources, fetching, and validation, delivering the data that smart contracts require. These elements bridge real-world data with blockchain systems.

### Oracle Nodes

Oracle nodes are the backbone of Chainlink’s data retrieval and processing system. Each node operates independently, gathering data from external APIs, data sources, and other platforms. Once data is collected, nodes verify and aggregate it through Chainlink’s consensus mechanism. They are responsible for authenticating and signing the data to ensure its integrity before it reaches the on-chain contracts.

### External Adapters

External adapters extend the flexibility of Chainlink nodes by enabling them to interact with a wide array of external data sources. Through these adapters, nodes can connect with APIs, databases, or proprietary systems to gather required data, which is essential for applications with specific or complex data needs.

### Off-Chain Reporting (OCR) Protocol

To handle data aggregation efficiently, Chainlink employs the Off-Chain Reporting (OCR) protocol. This protocol allows nodes to perform the consensus aggregation process off-chain, reducing gas fees and enhancing scalability. OCR groups multiple node responses and submits a single report on-chain, optimizing data flow and ensuring that resource-intensive consensus is performed only once.

## Consensus Mechanisms in Chainlink

Chainlink’s consensus system integrates multiple verification layers and economic incentives to prevent manipulation and enhance reliability. Here’s how Chainlink achieves a trust-minimized consensus across its decentralized network:

1. **Aggregation of Node Responses**: Chainlink nodes independently source and respond to data requests. Their responses are aggregated using consensus mechanisms, such as median calculations, to ensure outliers are disregarded. This redundancy strengthens the final output, mitigating the risk of data tampering or inaccuracies.

2. **Service Agreements and Reputation Scoring**: Chainlink nodes are ranked based on reputation metrics, including historical performance, accuracy, and speed. Only nodes with high reputation scores are selected for high-stakes data requests, fostering a competitive environment where reliability and performance are rewarded.

### 3. Cryptographic Proofs and Signatures

Each node response is cryptographically signed before submission to the aggregator contract. This allows smart contracts to verify the data’s authenticity and traceability back to the original source node.

## Enhanced Security Protocols in Chainlink

Given Chainlink’s critical role as a bridge between blockchains and external data, its security model incorporates multiple defenses:

- **Redundancy and Decentralization**: Chainlink nodes are distributed across various operators, geographies, and jurisdictions, reducing dependency on any single point of failure. This redundancy ensures that, even if a node fails or is attacked, data availability and integrity are maintained.
  
- **Staking and Penalty System**: Chainlink’s staking model incentivizes node operators to act honestly. If a node submits incorrect data, it risks losing its staked LINK, making dishonest behavior financially detrimental.
  
- **Randomness via VRF**: Chainlink’s Verifiable Random Function (VRF) provides secure randomness for blockchain applications, particularly in gaming and lottery-based smart contracts. VRF generates each random number with a cryptographic proof, which can be verified to prevent manipulation.

## Chainlink’s Data Flow

The typical data flow in Chainlink, from request initiation to final delivery, includes multiple steps to ensure security, reliability, and efficiency:

1. **Request Initiation**: A smart contract sends a data request to the Chainlink Oracle contract.

2. **Node Selection**: Suitable nodes are selected based on the Service Level Agreement (SLA), factoring in criteria like reputation and performance.

3. **Data Sourcing and Aggregation**: Nodes fetch data from external sources, validate, and sign it before submitting the results to the aggregator contract.

4. **Aggregation of Data On-Chain**: Responses are aggregated using consensus mechanisms to filter outliers, and the final result is sent to the requesting contract.

5. **Payment and Rewards Distribution**: Nodes are compensated in LINK according to the SLA terms, with penalties applied for poor performance.

# Setting Up a Chainlink Requesting Contract

To retrieve external data in a smart contract using Chainlink, you need to leverage the `ChainlinkClient` library provided by Chainlink. This library simplifies the process by handling the technicalities of making requests, fetching data, and aggregating responses.

## Explanation of the Requesting Contract

1. **Contract Initialization**: Configure essential Chainlink settings, including the Oracle address, job ID (a unique identifier specifying the type of data retrieval job), and the LINK fee.

2. **Data Request**: The `requestData` function sends a request to the Chainlink oracle to fetch external data. You specify the URL of the data source and the JSON path to the specific data of interest.

3. **Callback Function**: The `fulfill` function is a callback, automatically triggered once the requested data is available. The Chainlink nodes return the data, which is then stored in the `currentPrice` variable.

## Step-by-Step Guide

First, install the Chainlink client library in your development environment. You can use tools like Remix, Truffle, or Hardhat for this. Run the following command:

```bash
npm install --save @chainlink/contracts
```

# ChainlinkDataRequester Solidity Contract

This Solidity contract, `ChainlinkDataRequester`, interacts with the Chainlink oracle network to fetch off-chain data and store it on-chain. In this example, it retrieves BTC/USD price data from an external API and saves it in the `currentPrice` variable.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract ChainlinkDataRequester is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Chainlink Oracle Variables
    address private oracle; // Address of Chainlink node operator
    bytes32 private jobId; // Specific job ID for data retrieval
    uint256 private fee; // Fee for Oracle (usually in LINK tokens)
    
    // Data variable
    uint256 public currentPrice;

    constructor(address _oracle, bytes32 _jobId, uint256 _fee, address _linkToken) {
        setChainlinkToken(_linkToken); // Sets the LINK token address
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    function requestData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Define the data source URL and JSON path for data retrieval
        request.add("get", "https://api.coindesk.com/v1/bpi/currentprice/BTC.json");
        request.add("path", "bpi.USD.rate_float"); // Path to the data in the JSON response

        // Send request to the oracle
        requestId = sendChainlinkRequestTo(oracle, request, fee);
    }

    // Callback function to receive data
    function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) {
        currentPrice = _price; // Stores the retrieved data on-chain
    }
}
```

# Chainlink Aggregator Contract

The Chainlink Aggregator Contract is designed to aggregate multiple Oracle responses and achieve consensus by computing the median of responses from various nodes. Below is a basic implementation and explanation of how it works.

## Implementation of the Aggregator Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
    function getAnswer(uint80 _roundId) external view returns (int256);
}

contract PriceAggregator {
    AggregatorInterface internal aggregator;

    // Constructor to set the aggregator address
    constructor(address _aggregator) {
        aggregator = AggregatorInterface(_aggregator);
    }

    // Function to get the latest price
    function getLatestPrice() external view returns (int256) {
        return aggregator.latestAnswer();
    }
}
```

# Chainlink Aggregator Contract

This Solidity code implements a Chainlink Aggregator Contract, which interacts with Chainlink’s price feed aggregators to fetch the latest and historical price data for a specified asset. 

## Implementation of the Chainlink Aggregator Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
    function latestRound() external view returns (uint256);
    function getAnswer(uint256 roundId) external view returns (int256);
}

contract ChainlinkAggregator {
    AggregatorInterface internal priceFeed;

    constructor(address _priceFeed) {
        // For example, Chainlink's BTC/USD aggregator address on Ethereum mainnet
        priceFeed = AggregatorInterface(_priceFeed);
    }

    // Retrieve the latest aggregated price
    function getLatestPrice() public view returns (int256) {
        return priceFeed.latestAnswer();
    }

    // Retrieve price from a specific round (useful for historical data)
    function getHistoricalPrice(uint256 roundId) public view returns (int256) {
        return priceFeed.getAnswer(roundId);
    }
}
```

# Integrating Chainlink VRF for Random Number Generation

Chainlink provides a Verifiable Random Function (VRF) that enables smart contracts to request cryptographically secure random numbers. Below is an example of how to integrate VRF into a smart contract.

## Explanation of the VRF Contract

### 1. Initialization
The contract initializes the VRF consumer with the necessary parameters for requesting randomness from Chainlink VRF nodes:
- **`keyHash`**: A unique identifier for the VRF.
- **`fee`**: The LINK fee required to request randomness.

### 2. Requesting Randomness
The `getRandomNumber` function is responsible for requesting a random number from the VRF node. It returns a `requestId` that can be used to track the request.

### 3. Callback for Randomness
The `fulfillRandomness` function acts as the callback function, which Chainlink VRF nodes call with a cryptographically secure random number. This number is stored in the `randomResult` variable.

## Implementation of the VRF Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract ChainlinkVRFExample is VRFConsumerBase {
    bytes32 internal keyHash; // Chainlink VRF keyHash
    uint256 internal fee; // LINK fee

    uint256 public randomResult; // Variable to store the random number

    // Constructor to initialize the VRF consumer
    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee)
        VRFConsumerBase(_vrfCoordinator, _linkToken)
    {
        keyHash = _keyHash;
        fee = _fee;
    }

    // Function to request randomness
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Insufficient LINK"); // Check LINK balance
        return requestRandomness(keyHash, fee); // Request random number
    }

    // Callback function for Chainlink VRF
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness; // Store the random number
    }
}
```

## 4. Staking Mechanism for Chainlink Nodes

Chainlink currently doesn’t have a built-in staking mechanism directly in Solidity, but here’s a simple example of how a staking mechanism could theoretically be implemented to incentivize node honesty:

### Explanation of the Staking Contract:

1. **Stake Deposits**: Nodes can call the `stake` function to deposit Ether, which is then mapped to their address in `stakedAmounts`.

2. **Penalties**: The contract owner (e.g., a Chainlink manager) can penalize nodes by reducing their stake through the `penalize` function. This is a simplified mechanism to enforce node reliability and honesty in a decentralized manner.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChainlinkStaking {
    mapping(address => uint256) public stakedAmounts;
    address public owner;

    event Staked(address indexed user, uint256 amount);
    event Penalized(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function stake() external payable {
        require(msg.value > 0, "Stake must be greater than zero");
        stakedAmounts[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function penalize(address _node, uint256 _penaltyAmount) external onlyOwner {
        require(stakedAmounts[_node] >= _penaltyAmount, "Insufficient stake for penalty");
        stakedAmounts[_node] -= _penaltyAmount;
        emit Penalized(_node, _penaltyAmount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
```

## Integrating Pyth with your smart contract on the Kaia chain:

We have to get the address of the chain we are working with, in this case, Kaia:
`0x2880ab155794e7179c9ee2e38200202908c17b43`
We need the Pyth price feed ID of the Kaia chain: `0x2880ab155794e7179c9ee2e38200202908c17b43`


The next step is to copy the code below in the repository:
Pyth PriceFeed Integration

1. The file in the `PriceConverterPyth.sol` was created to generate the Klay price on the Pyth network.
It uses the price feed id of the currency KLAY/USD: 

2. Notice we need the price update data in the `PythPriceConverter.sol` file to get the most recently updated price data for the KLAY/USD. Usually, to generate that, you would need to make an API call to the Pyth network hermes API, but in the script file, `CreatePriceUpdateData.s.sol`, we have integrated the MockPyth which gives us access to the function that generates a price update data to fetch our price update data on our local development chain, ANVIL.

3. To see the MockPyth contract we used, check the `tests/mocks/MockPyth.sol` file in the repository.

4. In the `constants.sol`  file, we have the price data we used. Since there is no price data on a mock contract, we had to create one by importing the `PythStructs.sol`## file to generate a Pyth Price data and store it in our mapping “pricefeeds”. Now using a key “id”, we could access our stored price update data, and using the prices set, we could construct a price update data.


Create Update Data Locally(using MockPyth for the local test; for mainnet test, ensure to use the Hermes api). See the result below:

[Test result 1](https://lh3.googleusercontent.com/keep-bbsk/AFgXFlKpkLMSSIR7fQeGWZpb0NEAUSEg-Pu5pL31TWDLPZJuXokyxlEjNOBXEqMpva68GzJm9z6i5fgojNmrz0uLQ8gU4MMiR60fsiQt711tY6djzJJ_ilvUgg=s512)

[Test result 2](https://lh3.googleusercontent.com/keep-bbsk/AFgXFlLGThdQTCUa2TPJj6fVJCbTEMOY18QUihU7y0JHR0fWpmic3yeUzYyYMeJ5pqIUDtfz2GjrVGBpopF3KVcSxZDvh1vGOMlcBOVJt5VspiKlD4pEqBEmBQ=s512)


## Integrating Orakl with your smart contract on the Kaia chain:

This section will demonstrate how to fetch and utilize off-chain data using Orakl, a decentralized Oracle solution.

1. We will get some test KLAY tokens for the Kairos testnet

2. The next step is to copy the code below in the repository:
Orakl VRF Integration

3. The file in the `CoinFlip.sol` was created to generate random numbers on the Orakl network.

4.  In the code VRFConsumerBase was Inherited from Orakl's, VRF Coordinator interface was also imported.

5. The enumCoinFlipChoice represents the possible choices a player can make 

6. The Flip function in the `CoinFlip.sol` file allows a player to start a game, check if enough ETH is sent, request a random number from Orakl, and store game status, the players also call the Flip function with their choice of ETH.

7. The 'FullfillRandomWords' function in the CoinFlip file has a callback function called by Orakl VRF, the callback function determines game outcome Win /Loss and also handles payouts for winners.

8. The getStatus function is a helper function that helps to return the status of a specific game, The getBalance Function returns the contract's current balance

## Conclusion:

Integrating Oracle services into the Kaia blockchain ecosystem marks an important advancement in connecting on-chain and off-chain data. pull-based and push-based oracles, exemplified by Pyth Network and Orakl, offer developers flexible, wide options to optimize data freshness, cost efficiency, and update frequency. Kaia ecosystem, with its diverse oracle providers, demonstrates Kaia's maturity and potential for innovation in decentralized applications. As Kaia evolves, oracles will remain essential in expanding smart contract capabilities, combining deterministic blockchain technology with reliable external data feeds. 

You can also reference kaia docs for more info: https://docs.kaia.io/build/tools/oracles/

For a list of Oracle Providers supporting Kaia and their Integration in a smart contract on Kaia, visit the Kaia Oracle Toolkit repository: https://github.com/PaulElisha/Kaia-Oracle-Toolkit/


