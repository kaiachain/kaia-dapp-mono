# Integrating-Permit2-with-Kaia-Blockchain-A-Guide-to-Efficient-and-Secure-Token-Transfers

In the Ethereum ecosystem, interacting with decentralized applications (dApps) requires permission to move tokens on behalf of users. Conventionally, this involves a two-step process: first, the user grants an allowance using the approve() function, and then the protocol uses transferFrom() to transfer the tokens. While this method has long been the standard for ERC-20 tokens, it poses notable challenges in terms of user experience (UX) and security. To overcome these limitations, new approaches have been developed, including EIP-2612 and, more recently, Permit2, which builds on and enhances the capabilities of EIP-2612.

Notably, EIP-2612 introduced the concept of "permit" functions, which allow users to authorize token transfers without executing an on-chain transaction each time. This approach uses off-chain signatures, enabling users to grant permissions away from the blockchain while maintaining security. The permit function allows token owners to sign messages off-chain that authorize others to move specific amounts of tokens from their accounts. These signatures include crucial details like the amount, recipient, and duration of the permission.

 Building upon these concepts, more recent developments like Permit2 have extended and improved these ideas. These solutions aim to provide more efficient, cost-effective, and user-friendly ways for dApps to interact with token transfers within the Ethereum ecosystem. By streamlining the approval process and reducing gas costs, these innovations aim to enhance the overall user experience while maintaining security standards in decentralized applications. 

This article provides an in-depth explanation of Permit2, exploring its components, how it works, its features, and the security considerations when using it in decentralized applications and how to Integrate Permit2 on Kaia Blockchain

 - Introduction to Permit2
 - Features of Permit2
 - How to Use Permit2
 - Integration Of Permit2 To Kaia Blockchain


### Prerequisites
1. Fundamentals of Ethereum, ERC-20 tokens, and smart contracts.
2. EIP-2612, its limitations, and ERC-20 approval mechanics (approve(), transferFrom()).
3. Overview of Kaia Blockchain (for integration purposes).
4. Competency in Solidity for smart contract development.
5. Experience with dApps and wallets (e.g., kaia wallet).
6. API and smart contract integration.
7. Familiarity with Remix, Hardhat, Foundry, and cryptographic libraries.



## Introduction to Permit2

Permit2 is a smart contract designed to enable gasless token approvals and delegated token transfers for ERC-20 tokens. By using Permit2, users can authorize token transfers without paying gas for each approval. Instead, they sign an off-chain message that is validated on-chain by the Permit2 contract.
Permit2 is a smart contract that unifies the functionalities of two separate contracts: SignatureTransfer and AllowanceTransfer. These two contracts have different purposes, but they are frequently used together in decentralized finance and token management systems.
`
`SignatureTransfer`: A contract that allows for transfers based on a signature, bypassing the need for token allowances. The permissions granted by a signature are temporary and only last for the duration of the specific transaction for which the signature is valid.

`AllowanceTransfer`: A contract that allows users to set specific allowances for token spending. This gives the spender permission to spend a predefined amount of tokens for a specified time. Transfers via AllowanceTransfer are only successful if the proper allowances have been set beforehand.
By combining these two contracts, Permit2 allows developers to integrate both approaches into a single, unified contract, creating a more seamless and efficient experience for users and reducing the complexity of managing token transfers and permissions.

### Features of Permit2
1. `Signature-Based Transfers and Permissions`
One of the standout features of Permit2 is its ability to handle signature-based transfers. This feature is valuable because it bypasses the need to pre-approve token allowances, which often require additional transactions and can be cumbersome for users.
In the SignatureTransfer model, the owner of the tokens signs a message granting temporary permission to a spender to transfer tokens. The signature is valid for that specific transaction duration, which makes it convenient for single-use cases. For example, suppose a user wants to authorize a token transfer to another party for a one-time transaction. In that case, they can simply sign a message granting the required permission, without needing a long-term allowance setup.
In comparison, AllowanceTransfer requires the user to approve a specific amount of tokens that a spender can use. These allowances are typically set for a specific time frame and allow multiple transfers as long as the spender is within the approved limit.
Permit2 simplifies both of these models and combines them into a single contract, which allows developers to choose between the two approaches, depending on the use case, while maintaining a simple interface and reducing the risk of errors or inefficiencies in token management.

2. `Approval and Token Permissions`
Before a contract can request a user’s tokens, the user must approve Permit2 through the token contract. This is similar to the process of approving traditional token transfers but uses the Permit2 contract address for the approval.
For example, a user can approve the Permit2 contract to spend a certain amount of tokens:
```
solidity
USDC.approve(permit2Address, totalAmount);
```

To maximize efficiency, users are encouraged to use the max approval approach, which approves the Permit2 contract to spend an unlimited amount of tokens on behalf of the user:
```
solidity
totalAmount = type(uint256).max;
```
This maximizes the flexibility for the user and minimizes the need for repeated approvals.

3.`Transfer Functions`
Permit2 includes several transfer functions to handle token movement under both the SignatureTransfer and AllowanceTransfer models:

 `permitTransferFrom`: This function allows users to transfer a token from an owner through signature validation. The transfer is only successful if the signature is valid and matches the conditions specified by the owner.

`permitWitnessTransferFrom`: This is an extended version of the permitTransferFrom function, where an additional "witness" parameter is passed along with the signature. The witness is extra data (e.g., trade details) that the user also needs to sign, ensuring that other transaction conditions are validated alongside the transfer.

`permitTransferFrom (Batched)`: For multiple token transfers in a single transaction, the batched version allows users to transfer several tokens simultaneously, significantly reducing transaction costs and increasing efficiency.

`permitWitnessTransferFrom (Batched)`: The batched version of permitWitnessTransferFrom allows for multiple transfers while also validating extra data passed through the witness, offering more flexibility for complex transactions.

These functions provide multiple ways to transfer tokens depending on the requirements of the transaction and whether additional validation is necessary. By offering both single and batched transfer options, Permit2 caters to a wide range of use cases, from simple one-time transfers to complex, multi-token transfers that require extra data validation.

4.`Nonce Schema`
To prevent replay attacks (where the same signed message can be reused), Permit2 introduces a nonceBitmap mechanism. Instead of using traditional incrementing nonces, Permit2 uses a non-monotonic nonce schema based on a bitmap structure, where each owner’s address is mapped to a uint248 word position. The nonceBitmap uses 256 bits per bitmap to track the valid state of nonces.
```
solidity
mapping(address => mapping(uint248 => uint256)) public nonceBitmap;
```
The nonce is signed by the owner of the tokens, where the first 248 bits correspond to the word position, and the remaining 8 bits represent the specific bit position within that word. The nonceBitmap ensures that each signature is unique and prevents any replay of the signed message.
This mechanism enhances security by ensuring that the same signature cannot be reused multiple times, offering better protection against malicious attempts to duplicate valid signatures.

5.`Security Considerations`
While Permit2 offers powerful features, it is crucial to take into account potential security risks. A key consideration is verifying the origin of the transaction. If a signer (let’s say Bob) signs a permit to transfer tokens, an attacker (Eve) could steal Bob’s signature and submit it to a contract with herself as the recipient, allowing Eve to steal Bob’s tokens.

To mitigate such risks, contracts like Universal Router perform additional checks to ensure that the message sender (msg.sender) matches the expected spender address. By passing msg.sender as both the owner and from parameters, it ensures that only the intended spender can initiate the transfer, preventing unauthorized access to the tokens.

In addition to checking the origin of the transaction, integrating contracts must verify that the signature is being used for its intended purpose. This prevents malicious actors from exploiting valid signatures to conduct unauthorized transfers.

### How to Use Permit2
1. Initial Approval
Before any transfer, users must approve the Permit2 contract to manage their tokens. This is typically done once for a specific token, often with a maximum allowance value (e.g., uint256 max), and can be done by the user via the approve() function.

2. Off-Chain Signature Request
Once the initial approval is granted, dApps only need to request an off-chain signature from the user to approve specific transactions. The signature contains the allowance details (spender, value, deadline) and is verified by the Permit2 contract.

3. Token Transfer Execution
Once the Permit2 contract verifies the signature, it uses the pre-approved allowance to transfer tokens on behalf of the user. This reduces the need for users to approve every single transaction and minimizes gas costs.

### Advantages of Permit2
`Backward Compatibility`: Unlike EIP-2612, which required tokens to implement the permit() function, Permit2 works with all ERC-20 tokens, making it a universal solution for token approvals.

`Gas Efficiency`: Permit2 minimizes gas costs by allowing signature-based transfers. It reduces the need for multiple on-chain approvals and transfers, streamlining the process.

`Enhanced Security`: using expiration dates and offering a mechanism to revoke approvals at any time, Permit2 enhances security compared to traditional approval systems. Additionally, it limits the attack surface by consolidating approval checks into a single contract.

## Integration Of Permit2 To Kaia Blockchain

This guide outlines how to adapt and integrate Permit2 functionality for stateless operations on the Kaia blockchain. The integration demonstrates secure, decentralized, and efficient token transfer mechanisms using Permit2 or equivalent verifier/oracle logic on Kaia.

Permit2 is a standard that extends EIP-2612 by enabling generalized approvals and token allowances. In this integration, we:
1. Adapt Permit2 for Kaia’s stateless paradigm.
2. Integrate with Kaia’s verifier or oracle for ZKP and off-chain data interactions.
3. Test and deploy a CodeWithPermit2 equivalent tailored for Kaia.

## Architecture
1. `Permit2 Contract/Verifier`:
- Handles stateless transfer permits.
- Verifies signatures or ZK proofs for secure transfers.

2. `CodeWithPermit2 (Application Contract)`:
- Implements token transfer logic using Permit2.
- Emits events for auditing and tracking.

3. `Kaia-Specific Adaptations`:
- Statelessness: Use ZKP verification to ensure operations comply without maintaining state.
- Oracle Interaction: Retrieve token balances or allowances dynamically.

### Step-by-Step Integration

The GitHub repository below shows code to integrate permit2: https://github.com/PaulElisha/permit2-example-integration

This code defines the ICodeWithPermit2 interface for contracts that use Permit2, a gas-efficient, signature-based token transfer mechanism. Key components include:

#### Events:
`Permit2Transfer`: Logs transfers using the Permit2 system.
`AssetTransferred`: Logs general asset transfers.

#### Struct:
`TransferParam`: Groups the token address, receiver, and transfer amount.

#### Function:
`transferWithPermit2`: Executes token transfers using a cryptographic signature (sig) to authorize the transaction, based on Permit2's rules.

The interface serves as a blueprint for implementing signature-based token approvals and transfers, enhancing gas efficiency and user experience.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "permit2/interfaces/ISignatureTransfer.sol";

interface ICodeWithPermit2 {
    event Permit2Transfer(
        address indexed asset,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event AssetTransferred(
        address indexed asset,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    struct TransferParam {
        address asset;
        address receiver;
        uint256 amount;
    }

    function transferWithPermit2(
        TransferParam memory transferParam,
        ISignatureTransfer.PermitTransferFrom memory permit2Transfer,
        ISignatureTransfer.SignatureTransferDetails memory transferDetails,
        bytes memory sig
    ) external;
}
```

### Step 2: Create the Transfer Contract

The CodeWithPermit2 contract facilitates token transfers using the Permit2 system, which enables signature-based approvals for transfers. The key steps in the contract are:

`Validation`: It checks that the token and transfer parameters match, and ensures the sender's balance and the contract’s balance are sufficient.

`Permit2 Integration`: It uses the permitTransferFrom function from the Permit2 contract to authorize the transfer based on the signature.

`Transfer Execution`: It transfers the tokens to the receiver, ensuring the receiver’s balance increases and logs the transaction with events.

`Reverts on Failure`: If any checks fail (such as invalid parameters, insufficient balance, or transfer failure), the transaction reverts.

Overall, it securely and efficiently handles token transfers using Permit2’s signature-based system.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ICodeWithPermit2.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "permit2/Permit2.sol";
import "permit2/interfaces/ISignatureTransfer.sol";

contract CodeWithPermit2 is ICodeWithPermit2 {
    using SafeERC20 for IERC20;

    Permit2 private immutable permit2;

    constructor(Permit2 _permit2) {
        permit2 = _permit2;
    }

    function transferWithPermit2(
        TransferParam memory transferParam,
        ISignatureTransfer.PermitTransferFrom memory permit2Transfer,
        ISignatureTransfer.SignatureTransferDetails memory transferDetails,
        bytes memory sig
    ) public returns (bool) {
        if (transferParam.asset != permit2Transfer.permitted.token) {
            revert();
        }

        uint256 userBalance = IERC20(transferParam.asset).balanceOf(msg.sender);

        if (userBalance > 0) {
            if (
                transferDetails.to != address(this) ||
                transferDetails.requestedAmount > userBalance ||
                permit2Transfer.permitted.amount != transferDetails.amount
            ) {
                revert();
            }
        }

        uint256 contractBalance = IERC20(transferParam.asset).balanceOf(
            address(this)
        );

        permit2.permitTransferFrom(
            permit2Transfer,
            transferDetails,
            msg.sender,
            sig
        );

        if (contractBalance <= 0) {
            revert();
        }

        emit Permit2Transfer(
            transferParam.asset,
            msg.sender,
            address(this),
            transferDetails.requestedAmount
        );

        uint256 receiverBalanceBefore = IERC20(transferParam.asset).balanceOf(
            transferParam.receiver
        );

        transferParam.asset.safeTransfer(
            transferParam.receiver,
            transferParam.amount
        );

        uint256 receiverBalanceAfter = IERC20(transferParam.asset).balanceOf(
            transferParam.receiver
        );

        if (receiverBalanceAfter <= receiverBalanceBefore) {
            revert();
        }

        emit AssetTransferred(
            transferParam.asset,
            address(this),
            transferParam.receiver,
            transferDetails.requestedAmount
        );

        return true;
    }
}
```

### Step 3: Deploy the Contract

The DeployCodeWithPermit2 contract is a deployment script that deploys the CodeWithPermit2 contract, using an existing Permit2 contract at a specified address (kaia_permit2_address). It uses the Forge framework for deployment, with the run() function serving as the entry point. After deploying the CodeWithPermit2 contract, it returns both the deployed contract and the Permit2 contract reference.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./CodeWithKaiaPermit.sol";

contract DeployCodeWithKaiaPermit is Script {
    address private kaia_verifier_address = 0x...; // Address of deployed verifier

    function run() public returns (CodeWithKaiaPermit) {
        vm.startBroadcast();
        IKaiaPermit2 verifier = IKaiaPermit2(kaia_verifier_address);
        CodeWithKaiaPermit codeWithKaia = new CodeWithKaiaPermit(verifier);
        vm.stopBroadcast();

        return codeWithKaia;
    }
}
```

### Step 4: Test Your Contract
Testing is crucial to ensure everything works. We use a testing framework like Forge to simulate scenarios.
The DeployCodeWithPermit2 contract is a deployment script that uses the Forge framework to deploy the CodeWithPermit2 contract. It links the deployed CodeWithPermit2 contract with an existing Permit2 contract (at a specified address). The script deploys the contract and returns both the deployed CodeWithPermit2 contract and the Permit2 contract reference.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/CodeWithPermit2.sol";

contract DeployCodeWithPermit2 is Script {
    address private kaia_permit2_address =
        0xAFF6678E8F6eAe7B36d70bffffb7046Ee32D5e81;

    function run() public returns (CodeWithPermit2, Permit2) {
        return deployCodeWithPermit2();
    }

    function deployCodeWithPermit2() public returns (CodeWithPermit2, Permit2) {
        Permit2 _permit2 = Permit2(kaia_permit2_address);

        vm.startBroadcast();
        CodeWithPermit2 codeWithPermit2 = new CodeWithPermit2(_permit2);
        vm.stopBroadcast();

        return (codeWithPermit2, _permit2);
    }
}
```


The CodeWithPermit2Test contract is a unit test suite for the CodeWithPermit2 contract, which involves testing the transfer functionality using the Permit2 system. It uses the Forge testing framework. Here's a breakdown of the code:

#### State Variables:

`deployCodeWithPermit2`: Instance of the deployment contract for CodeWithPermit2.`
`codeWithPermit2`: Instance of the CodeWithPermit2 contract.
`transferParam`: Parameter structure for transfer details.
`kaia, mockERC20`: Token contracts used in the test.
`permit2`: The instance of the Permit2 contract.
`userA, userB`: Addresses for two users involved in the test.
`privateKey, domain_separator, sig`: Used for signing transactions in the test.
`mainnetFork`: Reference for the mainnet fork used in testing.

#### setUp() Function:

Initializes necessary contracts (mockERC20, permit2, codeWithPermit2).
Mints 100 ether of mockERC20 to userA and approves Permit2 for token transfers.
This function sets up the environment before the test runs, ensuring that the contract balances and approvals are in place.

`testTransferWithPermit2() Function`:
- This test validates the transferWithPermit2 function of the CodeWithPermit2 contract.
- It sets up the necessary data structures:

`transferParam`: Details for the transfer.

`permit2_`: Permission structure for transferring tokens from userA.

`sig`: Signature generated for the transfer.

`transferDetails_`: Details of the transfer.
The test then simulates the token transfer using Permit2, invoking transferWithPermit2 from userA to userB.

`Mock ERC20 Token`:
mockERC20 is used as a mock token for testing purposes, allowing minting and transfers of tokens during the test.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/CodeWithPermit2.sol";
import "../../script/DeployCodeWithPermit2.s.sol";
import "../../src/Interfaces/ICodeWithPermit2.sol";
import "permit2/Permit2.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../Helper/TestHelper.sol";
import "permit2/interfaces/IPermit2.sol";
import "permit2/interfaces/ISignatureTransfer.sol";
import "../mocks/MockERC20.sol";

contract CodeWithPermit2Test is Test, Constants, TestHelper {
    DeployCodeWithPermit2 deployCodeWithPermit2;
    CodeWithPermit2 codeWithPermit2;
    ICodeWithPermit2.TransferParam transferParam;
    IERC20 kaia;
    MockERC20 mockERC20;
    Permit2 permit2;

    address userA;
    address userB;

    uint256 privateKey;
    bytes32 domain_separator;
    bytes sig;

    uint256 internal mainnetFork;

    function setUp() public {
        mockERC20 = new MockERC20();
        permit2 = new Permit2();
        codeWithPermit2 = new CodeWithPermit2(permit2);

        // deployAssetScooper = new DeployAssetScooper();
        // (codeWithPermit2, permit2) = deployAssetScooper.run();

        privateKey = vm.envUint("PRIVATE_KEY");
        userA = vm.addr(privateKey);

        userB = makeAddr("USERB");

        console2.log(userA);

        vm.startPrank(userA);

        mockERC20.mint(userA, 100 ether);

        uint256 userABalance = mockERC20.balanceOf(userA);
        assertEq(
            userABalance,
            100 ether,
            "User A should have 100 ether after minting"
        );

        mockERC20.approve(address(permit2), type(uint256).max);

        vm.stopPrank();

        // aero = IERC20(AERO);

        // mainnetFork = vm.createFork(fork_url);
        // vm.selectFork(mainnetFork);
    }

    // function testMint() public {
    //     userA = makeAddr("userA");
    //     userB = makeAddr("userB");
    //     console2.log(userA);

    //     vm.startPrank(userA);

    //     mockERC20.mint(userA, 100 ether);

    //     uint256 balance = mockERC20.balanceOf(userA);
    //     assertEq(
    //         balance,
    //         100 ether,
    //         "User A should have 100 ether after minting"
    //     );

    //     vm.stopPrank();
    // }

    function testTransferWithPermit2() public {
        uint256 nonce = 0;
        domain_separator = permit2.DOMAIN_SEPARATOR();

        vm.startPrank(userA);
        mockERC20.approve(address(permit2), mockERC20.balanceOf(userA));
        vm.stopPrank();

        transferParam = createTransferParam(mockERC20, userB, amount);

        ISignatureTransfer.PermitTransferFrom
            memory permit2_ = defaultERC20PermitTransfer(
                address(mockERC20),
                nonce,
                mockERC20.balanceOf(userA)
            );

        sig = getPermitTransferSignature(
            permit2_,
            privateKey,
            address(codeWithPermit2),
            domain_separator
        );

        ISignatureTransfer.SignatureTransferDetails
            memory transferDetails_ = getTransferDetails(
                address(codeWithPermit2),
                mockERC20.balanceOf(userA)
            );

        vm.startPrank(userA);
        codeWithPermit2.transferWithPermit2(
            transferParam,
            permit2_,
            transferDetails_,
            sig
        );
        vm.stopPrank();
    }
}
```

### Conclusion

Permit2 represents a major leap in token approval systems. By abstracting the approval process into a standalone contract, it provides both backward compatibility and enhanced security features. Developers can now deliver a seamless user experience by allowing token approvals through off-chain signatures, while users enjoy gasless transactions and reduced friction. With the combination of allowance-based and signature-based transfers, Permit2 offers a flexible, scalable solution for modern dApps.
This is the future of token approval more efficient, more secure, and more user-friendly.

You can also reference kaia docs for more info: https://docs.kaia.io/build/tools/oracles/




