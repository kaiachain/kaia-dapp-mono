## **Fractionalizing NFTs on Kaia with KIP-7 Tokens**

When you own or manage high-value NFTs, especially in the world of decentralized finance (DeFi), fractionalizing them opens up unique opportunities. Imagine taking one highly coveted NFT—like a piece of digital art or a valuable in-game asset—and making it accessible to multiple investors by breaking it down into smaller, divisible tokens. 

Fractionalization doesn’t just increase accessibility; it boosts liquidity and invites DeFi functionalities like staking and lending. In this guide, I’ll show how to fractionalize an NFT on the Kaia blockchain by converting it into KIP-7 tokens, making it shareable, tradeable, and ready for DeFi integration on Kaia-compatible DEXs.

Let’s go step-by-step through tokenizing an NFT into a KIP-7 token to enable fractional ownership.


### **Why Fractionalize NFTs?**

First, let’s quickly cover why you’d want to fractionalize an NFT in the first place.

1. **Accessibility**: Fractionalization enables many users to access parts of an otherwise very expensive asset. Instead of buying the entire NFT, people can invest in a “slice” of it.
2. **Liquidity**: Fractionalizing NFTs makes it easier to trade shares of the NFT on decentralized exchanges (DEXs), enhancing the liquidity of the asset.
3. **DeFi Integration**: Once fractionalized, these NFT shares can be staked, swapped, or even used as collateral for lending protocols.

With these benefits in mind, let’s get into the technical part!

### **Objectives**
1. **Wrap an NFT**: Use a smart contract to wrap an NFT and convert it to a KIP-7 token.
2. **Enable Fractional Ownership**: Mint KIP-7 tokens to represent fractions of the NFT.
3. **DeFi Integration**: Enable trading and liquidity integration on DeFi platforms.


### **Prerequisites**
1. Basic familiarity with Solidity and smart contract development.
2. Access to [Remix IDE](https://ide.kaia.io/) for deploying and testing smart contracts.
3. A Kaia wallet with test [KLAY tokens](https://www.kaia.io/faucet) (for transactions).

In this tutorial, you’re working with two smart contracts on the Kaia blockchain: the ***Chels*** contract, which mints and manages NFTs using the KIP-17 standard, and the ***Chelsea*** contract, which allows for fractional ownership of these NFTs using the KIP-7 standard. This setup demonstrates how to wrap an NFT, issue fractional ownership through fungible tokens, and enable trading and redeeming these tokens for the underlying NFT value.

---

### **Overview of the Contracts**
1. **Chels Contract**:
    * This contract follows the **KIP-17** standard, Kaia’s equivalent of ERC-721, used for non-fungible tokens (NFTs).
    * The owner of the contract can mint NFTs by specifying the recipient address and a unique token ID.
2. **Chelsea Contract**:
    * This contract manages **fractional ownership** by wrapping an NFT inside it and minting **KIP-7** tokens, which represent ownership shares of the NFT.
    * It enables **buying**, **selling**, and **redeeming** the NFT with KLAY, and ensures that the NFT can only be redeemed when fractional tokens are burned.


### **Create the NFT Contract**

First, I’ll create an NFT contract using KIP-17. This contract will mint an NFT, which I’ll fractionalize into a KIP-7 token.

#### **Code for the NFT Contract (***Chels.sol***)**

1. Open Remix IDE and create a new file named ***Chels.sol***.

Paste the following code into the file: 
 
``` 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/access/Ownable.sol";

// Chels contract implements KIP17 standard for NFTs
contract Chels is KIP17, Ownable {
    // Initialize the NFT collection with a name and symbol
    constructor() KIP17("Chels", "CHT") {}

    // Mint an NFT to a specific address with a unique token ID
    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
```

* **KIP-17 Implementation**: Chels contract inherits from KIP-17, implementing Kaia’s NFT standard.
* **safeMint**: Only the contract owner can mint new NFTs by specifying an address (to) and a unique tokenId.


#### **Deploying the NFT Contract**

1. Go to **Solidity Compiler** in Remix, select version 0.8.4, and click **Compile Chels.sol**.
2. Open **Deploy & Run Transactions** and select **Injected Web3** as the environment to deploy on Kaia.
3. Deploy the contract by selecting Chels and clicking **Deploy**.
4. Copy the contract’s address once deployed; it will be needed for the next step.
5. To mint an NFT, use the ***safeMint*** function, inputting your address and a unique tokenId (e.g., 1).

It’s important to note that the KIP-17 contract must be deployed before the KIP-7 contract.

You can also verify the ownership of the NFT by clicking on the “***owner***” function, this should display your Kaia public address.

![Screenshot 2024-10-30 085234](https://github.com/user-attachments/assets/74f8d12c-b1ac-43f9-89a0-527850657f36)

Once the NFT is deployed, we can focus on the KIP-7 token.

![Screenshot 2024-10-30 172452](https://github.com/user-attachments/assets/aa3a4731-5ed9-43b4-b80d-dac36721b1a5)

---


### **Create the Fractional Ownership Token (KIP-7 Token)**

In this step, I’ll create a KIP-7 contract that will wrap the NFT, allowing users to purchase fractionalized ownership.

#### **Code for the Fractional Token Contract (***Chelsea.sol***)**

1. In Remix, create a new file named ***Chelsea.sol***.

Paste the following code:
 
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@klaytn/contracts@1.0.6/KIP/token/KIP7/KIP7.sol";
import "@klaytn/contracts@1.0.6/KIP/token/KIP17/IKIP17.sol";
import "@klaytn/contracts@1.0.6/access/Ownable.sol";
import "@klaytn/contracts@1.0.6/KIP/token/KIP7/extensions/draft-KIP7Permit.sol";
import "@klaytn/contracts@1.0.6/KIP/token/KIP17/utils/KIP17Holder.sol";

// Chelsea contract manages fractional ownership of NFTs using KIP-7 tokens

contract Chelsea is KIP7, Ownable, KIP7Permit, KIP17Holder {
    IKIP17 public collection; // The KIP-17 NFT contract
    uint256 public tokenId;   // The ID of the NFT being fractionalized
    bool public initialized = false; // Track whether the NFT has been initialized
    bool public forSale = false;      // Track if the NFT is up for sale
    uint256 public salePrice;         // Sale price of the NFT
    bool public canRedeem = false;    // Track if redemption is allowed

    // Constructor initializes KIP-7 token with name and symbol
    constructor() KIP7("Chelsea", "CHE") KIP7Permit("Chelsea") {}

    // Override function to support additional interfaces
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IKIP7Permit).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // Initialize the NFT by transferring it to this contract
    function initialize(address _collection, uint256 _tokenId) external onlyOwner {
        require(!initialized, "Already initialized");
        collection = IKIP17(_collection);  // Set the NFT collection
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);  // Transfer NFT
        tokenId = _tokenId;  // Store the token ID
        initialized = true;  // Mark as initialized
    }

    // Set the NFT for sale with a specified price
    function putForSale(uint256 price) external onlyOwner {
        salePrice = price;
        forSale = true;
    }

    // Purchase the NFT by paying the sale price in KLAY
    function purchase() external payable {
        require(forSale, "Not for sale");
        require(msg.value >= salePrice, "Insufficient KLAY");
        collection.transferFrom(address(this), msg.sender, tokenId);  // Transfer NFT
        forSale = false;
        canRedeem = true;  // Allow redemption of fractional tokens
    }

    // Redeem fractional tokens for a share of the NFT's value in KLAY
    function redeem(uint256 _amount) external {
        require(canRedeem, "Redemption not allowed");
        uint256 totalKei = address(this).balance;  // Get total KLAY balance
        uint256 toRedeem = (_amount * totalKei) / totalSupply();  // Calculate redeemable amount
        _burn(msg.sender, _amount);  // Burn the redeemed tokens
        payable(msg.sender).transfer(toRedeem);  // Transfer KLAY to the user
    }
}
```

#### **Deploying the KIP-7 Token Contract**
1. Compile Chelsea.sol in Remix using the **0.8.4** compiler.
2. Deploy the Chelsea contract and set the NFT’s contract address from the previous step.
3. **Initialize the Fractional Token Contract**:
    * Call the initialize function with the NFT collection contract address (from ***Chels.sol***) and the tokenId.
    * This will transfer the NFT to the Chelsea contract, allowing it to be fractionalized.

The smart contract for the KIP-7 must be an operator for the KIP-17 NFT token, so, in the ***“setApprovalForAll”*** function, paste the address of the KIP-7 token and also set the ***“approved”*** value to ***“true”***, then click on ***“transact”***.

The KIP-17 holder contract must be imported to avoid the KIP-17 Receiver Implementation error. This is compulsory if you want your contract to receive KIP-17 token.

![Screenshot 2024-10-30 163238](https://github.com/user-attachments/assets/0151c45e-0e53-409b-aafc-aa10ec698d2d)

---

### **Enabling Sale, Purchase, and Redeem Functions**

1. **Set a Sale Price**: Use the **sale** function, entering a sale price ([in Kei unit](https://docs.kaia.io/learn/kaia-native-token/#units-of-kaia-)) to enable the **purchase** function.
2. **Purchase**: Use the **purchase** function to acquire ownership of the fractionalized NFT, transferring the NFT from **Chelsea** to the buyer.
3. **Redeem**: Token holders can redeem their tokens for a share of the NFT’s value by calling the **redeem** function with the number of tokens they want to redeem in Kaia.

These tokens can be sent to other addresses also listed on DEXes or transferred to Multi-Sig wallet in the case of communities.

---

### **Conclusion**

By following this guide, you’ve created a fractionalized NFT ecosystem on Kaia, making high-value NFTs more accessible and liquid. From here, you can explore further DeFi functionalities, like staking or lending, to broaden the potential applications of fractional NFT ownership, these tutorials will be put out later but try these on your own. Always remember to test thoroughly, and if moving to production, prioritize security by undergoing audits and complying with relevant regulations.

### **References**

* [Kaia Documentation](https://docs.kaia.io/)
* [GitHub Repository](https://github.com/jorshimayor/fractionalize-nft)
