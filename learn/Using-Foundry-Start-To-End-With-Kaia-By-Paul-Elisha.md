### Using Foundry Start to End with kaia

## Introduction
Foundry has become an increasingly popular development environment for smart contracts because it requires only one language: Solidity. Kaia offers introductory documentation on using Foundry with kaia networks, which is recommended to read to get an introduction to using Foundry. In this tutorial, we will dip our toes deeper into the library to get a more cohesive look at properly developing, testing, and deploying with Foundry.

In this demonstration, we will deploy two smart contracts. One is a token, and the other will depend on that token. We will also write unit tests to ensure the contracts work as expected. To deploy them, we will write a script that Foundry will use to determine the deployment logic. Finally, we will verify the smart contracts on kaia's blockchain explorer.

## Checking Prerequisites
To get started, you will need the following:

Have an account with funds. You can get DEV tokens for testing on Kairos Testnet once every 24 hours from the Kairos Testnet Faucet
To test out the examples in this guide on kaia, you will need to have your own endpoint and API key, which you can get from one of the supported Endpoint Providers
Have Foundry installed
Have a KaiaScan API Key
Create a Foundry Project
The first step to start a Foundry project is, of course, to create it. If you have Foundry installed, you can run:

```bash
forge init foundry
cd foundry
```
This will have the forge utility initialize a new folder named foundry with a Foundry project initialized within it. The script, src, and test folders may have files in them already. Be sure to delete them, because we will be writing our own soon.

From here, there are a few things to do first before writing any code. First, we want to add a dependency to OpenZeppelin's smart contracts, because they include helpful contracts to use when writing token smart contracts. To do so, add them using their GitHub repository name:

```bash
forge install kaia/kaia-contracts
```

This will add the Kaia-contracts git submodule to your lib folder. To be sure that this dependency is mapped, you can override the mappings in a special file, remappings.txt:

```bash
forge remappings > remappings.txt
```

Every line in this file is one of the dependencies that can be referenced in the project's smart contracts. Dependencies can be edited and renamed so that it's easier to reference different folders and files when working on smart contracts. It should look similar to this with OpenZeppelin installed properly:

```bash
ds-test/=lib/forge-std/lib/ds-test/src/
forge-std/=lib/forge-std/src/
kaia-contracts/=lib/kaia-contracts/
```

Finally, let's open up the foundry.toml file. In preparation for Etherscan verification and deployment, add this to the file:

```bash
[profile.default]
src = 'src'
out = 'out'
libs = ['lib']
solc_version = '0.8.20'

[rpc_endpoints]
kaia = "https://rpc.kaia.network"
kaia = "INSERT_RPC_API_ENDPOINT"

[etherscan]
kaia = { key = "${KAIASCAN_API_KEY}" }
kaia = { key = "${KAIASCAN_API_KEY}" }
```

The first addition is a specification of the solc_version, underneath profile.default. The rpc_endpoints tag allows you to define which RPC endpoints to use when deploying to a named network, in this case, kaia. The etherscan tag allows you to add Etherscan API keys for smart contract verification, which we will review later.

## Add Smart Contracts
Smart contracts in Foundry destined for deployment by default belong in the src folder. In this tutorial, we'll write two smart contracts. Starting with the token:

```bash
touch MyToken.sol
```

Open the file and add the following to it:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin Contract
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// This ERC-20 contract mints the specified amount of tokens to the contract creator
contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MYTOK") {
        _mint(msg.sender, initialSupply);
    }

    // An external minting function allows anyone to mint as many tokens as they want
    function mint(uint256 toMint, address to) external {
        require(toMint <= 1 ether);
        _mint(to, toMint);
    }
}
```

As you can see, the OpenZeppelin ERC20 smart contract is imported by the mapping defined in remappings.txt.

The second smart contract, which we'll name Container.sol, will depend on this token contract. It is a simple contract that holds the ERC-20 token we'll deploy. You can create the file by executing:

```bash
touch Container.sol
```

Open the file and add the following to it:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Kaia Contract
import {MyToken} from "./MyToken.sol";

enum ContainerStatus {
    Unsatisfied,
    Full,
    Overflowing
}

contract Container {
    MyToken token;
    uint256 capacity;
    ContainerStatus public status;

    constructor(MyToken _token, uint256 _capacity) {
        token = _token;
        capacity = _capacity;
        status = ContainerStatus.Unsatisfied;
    }

    // Updates the status value based on the number of tokens that this contract has
    function updateStatus() public {
        address container = address(this);
        uint256 balance = token.balanceOf(container);
        if (balance < capacity) {
            status = ContainerStatus.Unsatisfied;
        } else if (balance == capacity) {
            status = ContainerStatus.Full;
        } else if (_isOverflowing(balance)) {
            status = ContainerStatus.Overflowing;
        }
    }

    // Returns true if the contract should be in an overflowing state, false if otherwise
    function _isOverflowing(uint256 balance) internal view returns (bool) {
        return balance > capacity;
    }
}
```

The Container smart contract can have its status updated based on how many tokens it holds and what its initial capacity value was set to. If the number of tokens it holds is above its capacity, its status can be updated to Overflowing. If it holds tokens equal to capacity, its status can be updated to Full. Otherwise, the contract will start and stay in the Unsatisfied state.

Container requires a MyToken smart contract instance to function, so when we deploy it, we will need logic to ensure that it is deployed with a MyToken smart contract.

## Write Tests
Before we deploy anything to a TestNet or MainNet, however, it's good to test your smart contracts. There are many types of tests:

Unit tests — allow you to test specific parts of a smart contract's functionality. When writing your own smart contracts, it can be a good idea to break functionality into different sections so that it is easier to unit test
Fuzz tests — allow you to test a smart contract with a wide variety of inputs to check for edge cases
Integration tests — allow you to test a smart contract when it works in conjunction with other smart contracts, so that you know it works as expected in a deployed environment
Forking tests - integration tests that allows you to make a fork (a carbon copy of a network), so that you can simulate a series of transactions on a preexisting network.

## Unit Tests in Foundry
To get started with writing tests for this tutorial, make a new file in the test folder:

```bash
cd test
touch MyToken.t.sol
```

By convention, all of your tests should end with .t.sol and start with the name of the smart contract that it is testing. In practice, the test can be stored anywhere and is considered a test if it has a function that starts with the word "test".

Let's start by writing a test for the token smart contract. Open up MyToken.t.sol and add:

```solidity
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;

    // Runs before each test
    function setUp() public {
        token = new MyToken(100);
    }

    // Tests if minting during the constructor happens properly
    function testConstructorMint() public {
        assertEq(token.balanceOf(address(this)), 100);
    }
}
```

Let's break down what's happening here. The first line is typical for a Solidity file: setting the Solidity version. The next two lines are imports. forge-std/Test.sol is the standard library that Forge (and thus Foundry) includes to help with testing. This includes the Test smart contract, certain assertions, and forge cheatcodes.

If you take a look at the MyTokenTest smart contract, you'll see two functions. The first is setUp, which is run before each test. So in this test contract, a new instance of MyToken is deployed every time a test function is run. You know if a function is a test function if it starts with the word "test", so the second function, testConstructorMint is a test function.

Great! Let's write some more tests, but for Container.

```bash
touch Container.t.sol
```

And add the following:

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {Container, ContainerStatus} from "../src/Container.sol";

contract ContainerTest is Test {
    MyToken public token;
    Container public container;

    uint256 constant CAPACITY = 100;

    // Runs before each test
    function setUp() public {
        token = new MyToken(1000);
        container = new Container(token, CAPACITY);
    }

    // Tests if the container is unsatisfied right after constructing
    function testInitialUnsatisfied() public {
        assertEq(token.balanceOf(address(container)), 0);
        assertTrue(container.status() == ContainerStatus.Unsatisfied);
    }

    // Tests if the container will be "full" once it reaches its capacity
    function testContainerFull() public {
        token.transfer(address(container), CAPACITY);
        container.updateStatus();

        assertEq(token.balanceOf(address(container)), CAPACITY);
        assertTrue(container.status() == ContainerStatus.Full);
    }
}
```

This test smart contract has two tests, so when running the tests, there will be two deployments of both MyToken and Container, for four smart contracts. You can run the following command to see the result of the test:

```bash
forge test
When testing, you should see the following output:

forge test
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/MyToken.t.sol:MyTokenTest
[PASS] testConstructorMint() (gas: 10651)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 361.83µs (39.46µs CPU time)

Ran 2 tests for test/Container.t.sol:ContainerTest
[PASS] testContainerFull() (gas: 73204)
[PASS] testInitialUnsatisfied() (gas: 18476)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 422.00µs (128.67µs CPU time)
Ran 2 test suites in 138.17ms (783.83µs CPU time): 3 tests passed, 0 failed, 0 skipped (3 total tests)
```

Test Harnesses in Foundry
Sometimes you'll want to unit test an internal function in a smart contract. To do so, you'll have to write a test harness smart contract, which inherits from the smart contract and exposes the internal function as a public one.

For example, in Container, there is an internal function named _isOverflowing, which checks to see if the smart contract has more tokens than its capacity. To test this, add the following test harness smart contract to the Container.t.sol file:

```solidity
contract ContainerHarness is Container {
    constructor(MyToken _token, uint256 _capacity) Container(_token, _capacity) {}

    function exposed_isOverflowing(uint256 balance) external view returns(bool) {
        return _isOverflowing(balance);
    }
}
```

Now, inside of the ContainerTest smart contract, you can add a new test that tests the previously unreachable _isOverflowing contract:

```solidity
// Tests for negative cases of the internal _isOverflowing function
function testIsOverflowingFalse() public {
    ContainerHarness harness = new ContainerHarness(token , CAPACITY);
    assertFalse(harness.exposed_isOverflowing(CAPACITY - 1));
    assertFalse(harness.exposed_isOverflowing(CAPACITY));
    assertFalse(harness.exposed_isOverflowing(0));
}
```

Now, when you run the test with forge test, you should see that testIsOverflowingFalse passes!

```bash
forge test
[⠊] Compiling...
[⠒] Compiling 1 files with 0.8.20
[⠢] Solc 0.8.20 finished in 1.06s
Compiler run successful

Ran 1 test for test/MyToken.t.sol:MyTokenTest
[PASS] testConstructorMint() (gas: 10651)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 498.00µs (48.96µs CPU time)

Ran 3 tests for test/Container.t.sol:ContainerTest
[PASS] testContainerFull() (gas: 73238)
[PASS] testInitialUnsatisfied() (gas: 18510)
[PASS] testIsOverflowingFalse() (gas: 192130)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 606.17µs (183.54µs CPU time)
Ran 2 test suites in 138.29ms (1.10ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```

## Fuzzing Tests in Foundry
When you write a unit test, you can only use so many inputs to test. You can test edge cases, a few select values, and perhaps one or two random ones. But when working with inputs, there are nearly an infinite amount of different ones to test! How can you be sure that they work for every value? Wouldn't you feel safer if you could test 10000 different inputs instead of less than 10?

One of the best ways that developers can test many inputs is through fuzzing, or fuzz tests. Foundry automatically fuzz tests when an input in a test function is included. To illustrate this, add the following test to the MyTokenTest contract in MyToken.t.sol.

```solidity
// Fuzz tests for success upon minting tokens one ether or below
function testMintOneEtherOrBelow(uint256 amountToMint) public {
    vm.assume(amountToMint <= 1 ether);

    token.mint(amountToMint, msg.sender);
    assertEq(token.balanceOf(msg.sender), amountToMint);
}
```

This test includes uint256 amountToMint as input, which tells Foundry to fuzz with uint256 inputs! By default, Foundry will input 256 different inputs, but this can be configured with the FOUNDRY_FUZZ_RUNS environment variable.

Additionally, the first line in the function uses vm.assume to only use inputs that are less than or equal to one ether since the mint function reverts if someone tries to mint more than one ether at a time. This cheatcode helps you direct the fuzzing into the right range.

Let's look at another fuzzing test to put in the MyTokenTest contract, but this time where we expect to fail:

```solidity
// Fuzz tests for failure upon minting tokens above one ether
function testFailMintAboveOneEther(uint256 amountToMint) public {
    vm.assume(amountToMint > 1 ether);

    token.mint(amountToMint, msg.sender);
}
```

In Foundry, when you want to test for a failure, instead of just starting your test function with the world "test", you start it with "testFail". In this test, we assume that the amountToMint is above one ether, which should fail!

Now run the tests:

```bash
forge test
You should see something similar to the following in the console:

forge test
[⠊] Compiling...
[⠊] Compiling 1 files with 0.8.20
[⠒] Solc 0.8.20 finished in 982.65ms
Compiler run successful

Ran 3 tests for test/Container.t.sol:ContainerTest
[PASS] testContainerFull() (gas: 73238)
[PASS] testInitialUnsatisfied() (gas: 18510)
[PASS] testIsOverflowingFalse() (gas: 192130)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 446.25µs (223.67µs CPU time)

Ran 3 tests for test/MyToken.t.sol:MyTokenTest
[PASS] testConstructorMint() (gas: 10651)
[PASS] testFailMintAboveOneKlay(uint256) (runs: 256, μ: 8462, ~: 8462)
[PASS] testMintOneEtherOrBelow(uint256) (runs: 256, μ: 37939, ~: 39270)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 10.78ms (18.32ms CPU time)
Ran 2 test suites in 138.88ms (11.23ms CPU time): 6 tests passed, 0 failed, 0 skipped (6 total tests)
```

##  Tests in Foundry
In Foundry, you can locally fork a network so that you can test out how the contracts would work in an environment with already deployed smart contracts. For example, if someone deployed smart contract A on Kaia that required a token smart contract, you could fork the Kaia network and deploy your own token to test how smart contract A would react to it.

Note

Kaia's custom precompile smart contracts currently do not work in Foundry forks because precompiles are Substrate-based whereas typical smart contracts are completely based on the EVM. Learn more about forking on Kaia and the differences between Kaia and Ethereum.

In this tutorial, you will test how your Container smart contract interacts with an already deployed MyToken contract on Kairos Testnet

Let's add a new test function to the ContainerTest smart contract in Container.t.sol called testAlternateTokenOnKaiaFork:

```solidity
// Fork tests in the Kairos environment
function testAlternateTokenOnKairosFork() public {
    // Creates and selects a fork, returns a fork ID
    uint256 KairosFork = vm.createFork("Kairos");
    vm.selectFork(KairosFork);
    assertEq(vm.activeFork(), KairosFork);

    // Get token that's already deployed & deploys a container instance
    token = MyToken(0x359436610E917e477D73d8946C2A2505765ACe90);
    container = new Container(token, CAPACITY);

    // Mint tokens to the container & update container status
    token.mint(CAPACITY, address(container));
    container.updateStatus();

    // Assert that the capacity is full, just like the rest of the time
    assertEq(token.balanceOf(address(container)), CAPACITY);
    assertTrue(container.status() == ContainerStatus.Full);
}
```

The first step (and thus first line) in this function is to have the test function fork a network with vm.createFork. Recall that vm is a cheat code provided by the Forge standard library. All that's necessary to create a fork is an RPC URL, or an alias for an RPC URL that's stored in the foundry.toml file. In this case, we added an RPC URL for "Kairos" in the setup step, so in the test function we will just pass the word "Kairos". This cheat code function returns an ID for the fork created, which is stored in an uint256 and is necessary for activating the fork.

On the second line, after the fork has been created, the environment will select and use the fork in the test environment with vm.selectFork. The third line just demonstrates that the current fork, retrieved with vm.activeFork, is the same as the Kairos fork.

The fourth line of code retrieves an already deployed instance of MyToken, which is what's so useful about forking: you can use contracts that are already deployed.

The rest of the code tests capacity like you would expect a local test to. If you run the tests (with the -vvvv tag for extra logging), you'll see that it passes:

```bash
forge test -vvvv
forge test
[PASS] testIsOverflowingFalse() (gas: 192130)
Traces:
 [192130] ContainerTest::testIsOverflowingFalse()
 ├─ [151256] → new ContainerHarness@0xF62849F9A0B5Bf2913b396098F7c7019b51A820a
 │ └─ ← [Return] 522 bytes of code
 ├─ [421] ContainerHarness::exposed_isOverflowing(99) [staticcall]
 │ └─ ← [Return] false
 ├─ [0] VM::assertFalse(false) [staticcall]
 │ └─ ← [Return]
 ├─ [421] ContainerHarness::exposed_isOverflowing(100) [staticcall]
 │ └─ ← [Return] false
 ├─ [0] VM::assertFalse(false) [staticcall]
 │ └─ ← [Return]
 ├─ [421] ContainerHarness::exposed_isOverflowing(0) [staticcall]
 │ └─ ← [Return] false
 ├─ [0] VM::assertFalse(false) [staticcall]
 │ └─ ← [Return]
 └─ ← [Stop]
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.07s (2.07s CPU time)
Ran 2 test suites in 2.44s (2.08s CPU time): 7 tests passed, 0 failed, 0 skipped (7 total tests)
That's it for testing! You can find the complete Container.t.sol and MyToken.t.sol files below:

Container.t.sol
MyToken.t.sol
```

Deploy in Foundry with Solidity Scripts
Not only are tests in Foundry written in Solidity, the scripts are too! Like other developer environments, scripts can be written to help interact with deployed smart contracts or can help along a complex deployment process that would be difficult to do manually. Even though scripts are written in Solidity, they are never deployed to a chain. Instead, much of the logic is actually run off-chain, so don't worry about any additional gas costs for using Foundry instead of a JavaScript environment like Hardhat.

Deploy on Kairos Alpha
In this tutorial, we will use Foundry's scripts to deploy the MyToken and Container smart contracts. To create the deployment scripts, create a new file in the script folder:

```bash
cd script
touch Container.s.sol
```

By convention, scripts should end with s.sol and have a name similar to the script they relate to. In this case, we are deploying the Container smart contract, so we have named the script Container.s.sol, though it's not the end of the world if you use a more suitable or descriptive name.

In this script, add:

```solidity
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";
import {Container} from "../src/Container.sol";

contract ContainerDeployScript is Script {
    // Runs the script; deploys MyToken and Container
    function run() public {
        // Get the private key from the .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Make a new token
        MyToken token = new MyToken(1000);

        // Make a new container
        new Container(token, 500);

        vm.stopBroadcast();
    }
}
```

Let's break this script down. The first line is standard: declaring the solidity version. The imports include the two smart contracts you previously added, which will be deployed. This includes additional functionality to use in a script, including the Script contract.

Now let's look at the logic in the contract. There is a single function, run, which is where the script logic is hosted. In this run function, the vm object is used often. This is where all of the Forge cheatcodes are stored, which determines the state of the virtual machine that the solidity is run in.

In the first line within the run function, vm.envUint is used to get a private key from the system's environment variables (we will do this soon). In the second line, vm.startBroadcast starts a broadcast, which indicates that the following logic should take place on-chain. So when the MyToken and the Container contracts are instantiated with the new keyword, they are instantiated on-chain. The final line, vm.stopBroadcast ends the broadcast.

Before we run this script, let's set up some of our environment variables. Create a new .env file:

```bash
touch .env
```

And within this file, add the following:

```bash
PRIVATE_KEY=YOUR_PRIVATE_KEY
KAIASCAN_API_KEY=YOUR_KAIASCAN_API_KEY
```
Note

Foundry provides additional options for handling your private key. It is up to you to decide whether or not you would rather use it in the console, have it stored in your device's environment, using a hardware wallet, or using a keystore.

To add these environment variables, run the following command:

```bash
source .env
```

Now your script and project should be ready for deployment! Use the following command to do so:


forge script Container.s.sol:ContainerDeployScript --broadcast --verify -vvvv --legacy --rpc-url Kairos
This command runs the ContainerDeployScript contract as a script. The --broadcast option tells Forge to allow broadcasting of transactions, the --verify option tells Forge to verify to KAIASCAN when deploying, -vvvv makes the command output verbose, and --rpc-url Kairos sets the network to what Kairos was set to in foundry.toml. The --legacy flag instructs Foundry to bypass EIP-1559. While all Kaia networks support EIP-1559, Foundry will refuse to submit the transaction to Kairos and revert to a local simulation if you omit the --legacy flag.

You should see something like this as output:

```bash
Script ran successfully.
Setting up 1 EVM.
Simulated On-chain Traces:
 [488164] → new MyToken@0xAEe1a769b10d03a6CeB4D9DFd3aBB2EF807ee6aa
 ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x3B939FeaD1557C741Ff06492FD0127bd287A421e, value: 1000)
 └─ ← [Return] 1980 bytes of code
 [133238] → new Container@0xeb1Ff38A645Eae4E64dFb93772D8129F88E11Ab1
 └─ ← [Return] 432 bytes of code
Chain 1287
Estimated gas price: 0.125 gwei
Estimated total gas used for script: 1670737
Estimated amount required: 0.000208842125 ETH
Sending transactions [0 - 0].
⠁ [00:00:00] [#############################################################>-------------------------------------------------------------] 1/2 txes (0.7s)
Waiting for receipts.
⠉ [00:00:22] [#######################################################################################################################] 1/1 receipts (0.0s)
Kairos
✅ [Success]Hash: 0x2ad8994c12af74bdcb04873e13d97dc543a2fa7390c1e194732ab43ec828cb3b
Contract Address: 0xAEe1a769b10d03a6CeB4D9DFd3aBB2EF807ee6aa
Block: 6717135
Paid: 0.000116937 ETH (935496 gas * 0.125 gwei)
Sending transactions [1 - 1].
⠉ [00:00:23] [###########################################################################################################################] 2/2 txes (0.0s)
Waiting for receipts.
⠉ [00:00:21] [#######################################################################################################################] 1/1 receipts (0.0s)
Kairos
✅ [Success]Hash: 0x3bfb4cee2be4269badc57e0053d8b4d94d9d57d7936ecaa1e13ac1e2199f3b12
Contract Address: 0xeb1Ff38A645Eae4E64dFb93772D8129F88E11Ab1
Block: 6717137
Paid: 0.000035502 ETH (284016 gas * 0.125 gwei)
ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.000152439 ETH (1219512 gas * avg 0.125 gwei)
```

You should be able to see that your contracts were deployed, and are verified on KAIASCAN! For example, this is where my Container.sol contract was deployed.

The entire deployment script is available below:

Container.s.sol
Deploy on Kaia MainNet
Let's say that you're comfortable with your smart contracts and you want to deploy on the Kaia MainNet! The process isn't too different from what was just done, you just have to change the command's rpc-url from Kairos to Kaia, since you've already added Kaia MainNet's information in the foundry.toml file:


forge script Container.s.sol:ContainerDeployScript --broadcast --verify -vvvv --legacy --rpc-url Kaia
It's important to note that there are additional, albeit more complex, ways of handling private keys in Foundry. Some of these methods can be considered safer than storing a production private key in environment variables.

That's it! You've gone from nothing to a fully tested, deployed, and verified Foundry project. You can now adapt this so that you can use Foundry in your own projects!
