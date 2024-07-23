# Implementing Fee Delegation in Klaytn DApps

Klaytn offers various features to enhance the developer and user experience. One of the key features is **Fee Delegation**, which allows developers to pay the transaction fees on behalf of users. This can significantly reduce the friction of transaction fees for users, making DApps more user-friendly. In this guide, we'll explore how to implement Fee Delegation in Klaytn DApps using the Fee Delegation SDK, with practical examples and code snippets.

## Understanding Fee Delegation

Fee Delegation in Klaytn allows a third party, usually the DApp developer or service provider, to pay for the transaction fees instead of the user. This is particularly useful in scenarios where you want to provide a seamless user experience without burdening users with the cost of transactions.

### Types of Fee Delegation

- **Basic Fee Delegation:** The fee payer signs the transaction, and the user pays no fees.
- **Partial Fee Delegation:** The fee is shared between the user and the fee payer.

## Setting Up the Fee Delegation SDK

To get started with Fee Delegation, you'll need to set up the Klaytn Fee Delegation SDK. Follow these steps:

**Note:** This is for educational purposes. The full implementation requires backend service as seen in the Klaytn [docs](https://docs.klaytn.foundation/).

### Step 1: Install the SDK

First, install the Klaytn Fee Delegation SDK in your project. You can use npm to install it:

```javascript
npm install @klaytn/feedelegation-sdk

const senderAddress = '0x...'; // User's address
const feePayerAddress = '0x...'; // Fee payer's address
const feePayerPrivateKey = '0x...'; // Fee payer's private key

async function createFeeDelegationTransaction() {
    // Define transaction parameters
    const txParams = {
        from: senderAddress,
        to: '0x...', // Recipient address
        value: caver.utils.toPeb('1', 'KLAY'), // Amount in KLAY
        gas: 300000, // Gas limit
        gasPrice: caver.utils.toPeb('25', 'Gpeb') // Gas price
    };

    // Create a transaction object
    const tx = await feeDelegation.transaction.create(txParams);

    // Sign the transaction with the sender's private key
    const signedTx = await caver.klay.accounts.signTransaction(tx, senderPrivateKey);

    // Sign the transaction with the fee payer's private key
    const feePayerSignedTx = await feeDelegation.signTransactionAsFeePayer(signedTx, feePayerPrivateKey);

    // Send the transaction
    const receipt = await caver.klay.sendSignedTransaction(feePayerSignedTx);
    console.log('Transaction receipt:', receipt);
}

createFeeDelegationTransaction().catch(console.error);
```

## Example: Fee Delegation in a Smart Contract Interaction
Let’s take a practical example of interacting with a smart contract using Fee Delegation. Suppose we have a simple smart contract that records a message on the blockchain. We want to allow users to record messages without paying the transaction fees.

### Step 1: Deploy the Smart Contract
Here’s a simple smart contract in Solidity:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageRecorder {
    event MessageRecorded(address indexed sender, string message);

    function recordMessage(string calldata message) external {
        emit MessageRecorded(msg.sender, message);
    }
}
```
Deploy the contract on the Klaytn network using Remix or any other tool you prefer.

### Step 2: Interact with the Smart Contract Using Fee Delegation
Now, let’s write a script to interact with the MessageRecorder contract using Fee Delegation:

```javascript
const { FeeDelegation, Klaytn } = require('@klaytn/feedelegation-sdk');
const caver = new Klaytn('https://api.cypress.klaytn.net:8651'); // Mainnet endpoint

// Initialize FeeDelegation
const feeDelegation = new FeeDelegation(caver);

// Contract details
const contractAddress = '0x...'; // Deployed contract address
const abi = [/* Contract ABI */];
const contract = new caver.klay.Contract(abi, contractAddress);

// Addresses and keys
const senderAddress = '0x...'; // User's address
const senderPrivateKey = '0x...'; // User's private key
const feePayerAddress = '0x...'; // Fee payer's address
const feePayerPrivateKey = '0x...'; // Fee payer's private key

async function recordMessageWithFeeDelegation(message) {
    // Define the transaction
    const txParams = {
        type: 'FEE_DELEGATED_SMART_CONTRACT_EXECUTION',
        from: senderAddress,
        to: contractAddress,
        data: contract.methods.recordMessage(message).encodeABI(),
        gas: 300000
    };

    // Sign the transaction with the sender's private key
    const signedTx = await caver.klay.accounts.signTransaction(txParams, senderPrivateKey);

    // Sign the transaction with the fee payer's private key
    const feePayerSignedTx = await feeDelegation.signTransactionAsFeePayer(signedTx, feePayerPrivateKey);

    // Send the transaction
    const receipt = await caver.klay.sendSignedTransaction(feePayerSignedTx);
    console.log('Transaction receipt:', receipt);
}

recordMessageWithFeeDelegation('Hello, Klaytn!').catch(console.error);
```
For a standard approach, refer to the official GitHub repository.

## Conclusion
Implementing Fee Delegation in your Klaytn DApps can greatly enhance the user experience by removing the burden of transaction fees. The Fee Delegation SDK provides a straightforward way to achieve this, allowing developers to create more accessible and user-friendly applications. By following the steps outlined in this guide, you can integrate Fee Delegation into your DApps, making blockchain interactions seamless for your users.

Happy coding! 🚀