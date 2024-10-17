# Understanding EIP-712: A Beginner's Guide to Typed Data Signing in Ethereum

Oftentimes, User Interaction issues might arise when it comes to signing messages and transactions securely. There is no way to verify exactly what transaction you are signing from your wallet as it displays just a bytes string and that makes the wallet holder vulnerable to attacks as they are oblivion of what they are signing which could lead to loss of tokens from their wallet.

The objective of this article is to help you to understand what improvement exactly is EIP 712 adding to the Web3 space, the underlying architecture and the integration process.

At the end of the article, you will understand how to build a smart contract that uses the features of EIP 712 for meta transactions.

## Prerequisites:

1. A solid understanding of writing smart contract with solidity.
2. An understanding of utilizing foundry framework in smart contract developments.
3. An understanding of EIP 191 which would be covered in this article.
4. An understanding of Digital Signatures - ECDSA.
5. An understanding of precompiled contracts.

So sit back and keep reading...

## What is EIP-712?

Before we go further, see the picture below:

(![Image1](https://eips.ethereum.org/assets/eip-712/eth_sign.png))

That was how transactions data used to appear to the user which is blindly signed ignorant of the content. The transaction or message data is constructed like this:

```solidity
    function getSignerSimple(
        uint256 message,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public pure returns (address) {
        bytes32 hashedMessage = bytes32(message); 
        // if string, we'd use keccak256(abi.encodePacked(string))
    }
```

and they are signed like this:

```solidity
    function getSignerSimple(
        uint256 message,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public pure returns (address) {
        bytes32 hashedMessage = bytes32(message); // if string, we'd use keccak256(abi.encodePacked(string))
        address signer = ecrecover(hashedMessage, _v, _r, _s);
        return signer;
    }
```
where `ecrecover` is a precompile native to ethereum used to recover the address of the signer, using ECDSA, whose signature was applied on the message data or transaction data using their private key, and the verification is done by comparing the signer to the supposed signer passed as a function parameter, using the below function:

```solidity
    function verifySignerSimple(
        uint256 message,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        address signer
    ) public pure returns (bool) {
        address actualSigner = getSignerSimple(message, _v, _r, _s);
        require(signer == actualSigner);
        return true;
    }
```

However, it comes with a lot of risks which could potentially lead to loss of tokens in a user wallet when they apply signatures on oblivious, random data. So, we need a way to dictate how the message data should be constructed for the user to see and verify that they are signing the right transaction. 

## EIP-712

EIP-712, or Ethereum Improvement Proposal 712, is a standard for hashing, structuring and signing typed structured data in Ethereum, improving User Interaction, readability and ensuring specificity to certain contracts. The primary goal of EIP-712 is to provide a way to prevent the users from misusing signatures by allowing developers to define a clear structure for the data being signed, which adds an extra layer of security as seen in the image below:

(![Image2](https://eips.ethereum.org/assets/eip-712/eth_signTypedData.png))

## Motivation

As seen in the ethereum eip website (eips.ethereum.org/EIPS/eip-712):

"As such, the adage 'don’t roll your own crypto' applies. Instead, a peer-reviewed well-tested standard method needs to be used. This EIP aims to be that standard.

This EIP aims to improve the usability of off-chain message signing for use on-chain. We are seeing growing adoption of off-chain message signing as it saves gas and reduces the number of transactions on the blockchain. Currently signed messages are an opaque hex string displayed to the user with little context about the items that make up the message."

`**Data Structure**`

To define the structured data, it is imperative to declare using understandable types related to solidity and adopting solidity notations illustrates and explains the type declaration or definition.

```solidity
    struct Mail {
    address from;
    address to;
    string contents;
}
```

`**Hash Struct**`

The hash struct involves the typeHash, a convention used when the type of a struct is encoded or hashed and the hash of the message. This is what makes the message readable before signing.

```solidity
    keccak256(Mail(address from, address to, string contents));
```
```solidity
    keccak256(abi.encode(Mail({from: _from; to: _to; contents: _contents})));
```

`**Domain Separator**`

A struct defining the domaain of the message being signed must be defined.

```solidity
    struct EIP712Domain {	
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        // bytes32 salt; not required
    }
```
using the hash struct , we can get the domain Separator.

```solidity

// Define what the "domain" struct looks like.
EIP712Domain eip_712_domain_separator_struct = EIP712Domain({
	name: "SignatureVerifier", // this can be anything
	version: "1", // this can be anything
	chainId: 1, // ideally the chainId
	verifyingContract: address(this) // ideally, set this as "this", but can be any contract to verify signatures
});

The executing contract verifies this metadata in order to ensure that the signed transaction is only executed on the target contract.

// Now the format of the signatures is known, define who is going to verify the signatures.
bytes32 public immutable i_domain_separator = keccak256(
	abi.encode(
		EIP712DOMAIN_TYPEHASH,
		keccak256(bytes(eip_712_domain_separator_struct.name)),
		keccak256(bytes(eip_712_domain_separator_struct.version)),
		eip_712_domain_separator_struct.chainId,
		eip_712_domain_separator_struct.verifyingContract
	)
);
```

This means that contracts can know whether the signature was created specifically for themselves or not. That is, the domain separator makes the application context unique, it's like how a chain-id differentiates between chains.

Before the EIP712 standard, we had the EIP191 standard used to facilitate already made signatures or sponsored transactions - that is, you can sign a message and approve someone to send the transaction using their gas fees.

## EIP-712 Format

The EIP 712 signature standard has a format that ensures structuring of signed data:

`0x19 0x01 <domainSeparator> <hashStruct(message)>`

- The initial 0x19 byte is intended to ensure that the signed_data is not valid RLP.

For a single byte whose value is in the [0x00, 0x7f] range, that byte is its own RLP encoding.

That means that any signed_data cannot be one RLP-structure, but a 1-byte RLP payload followed by something else. Thus, any EIP-191 signed_data can never be an Ethereum transaction.

Additionally, 0x19 has been chosen because since ethereum/go-ethereum#2940 , the following scheme is prepended before hashing in personal_sign:

"\x19Ethereum Signed Message:\n" + len(message).

-  Version 0x01
The version 0x01 is for typed structured data as defined in EIP-712.

- Domain Separator: Version-specific data.

The data specific to the version (EIP-712).

- hashStruct
The hash of the message or data, which has been explained earlier.

## Implementing EIP 712 in your smart contract.

**Steps for EIP 712 implementation:**

1. Define a domain separator struct with essential data.
struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
};

2. Hash the struct and its type hash to create the domain separator.
bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

3. Create a message type hash and combine it with the message data to generate a hashed message.

bytes32 public constant MESSAGE_TYPEHASH = keccak256("Message(uint256 number)");
bytes32 hashedMessage = keccak256(abi.encode(MESSAGE_TYPEHASH, Message({ number: message })));

4. Combine all elements with a prefix and version byte to form a final digest.
Use ecrecover with the digest and signature to retrieve the signer's address and verify authenticity.

```solidity
contract SignatureVerifier {

    function getSignerEIP712(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
        // Prepare data for hashing
        bytes1 prefix = bytes1(0x19);
        bytes1 eip712Version = bytes1(0x01); // EIP-712 is version 1 of EIP-191
        

        EIP712Domain domainSeparator = EIP712Domain({
            Name: _name
            Version: 1
            Chainid: block.chainid
            Verifying Contract: address(this)
        });

        bytes32 hashStructOfDomainSeparator = Keccak256
        (
        abi.encodePacked
        (
        EIP712DOMAIN_TYPEHASH,
        keccak256(bytes32(domainSeparator.name)),
        keccak256(bytes32(domaninSeparator.version)),
        domainSeparator.chainid,
        domainSeparator.verifyingContract
            )
        )

                // Hash the message struct
                bytes32 hashedMessage = keccak256(abi.encode(MESSAGE_TYPEHASH, Message({ number: message })));

                // Combine all elements
                bytes32 digest = keccak256(abi.encodePacked(prefix, eip712Version, hashStructOfDomainSeparator, hashedMessage));
                return ecrecover(digest, _v, _r, _s);
            }
}
```

We can then verify the signer as in the first example, but using verifySignerEIP712:

```solidity
function verifySignerEIP712(
    uint256 message,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    address signer
) public view returns (bool) {
    address actualSigner = getSignerEIP712(message, _v, _r, _s);
    require(signer == actualSigner);
    return true;
}
```

## EIP 712: OpenZeppelin

It's recommended to use OpenZeppelin libraries to simplify the process, by using EIP712::_hashTypedDataV4 function:
Create the message type hash and hash it with the message data:
bytes32 public constant MESSAGE_TYPEHASH = keccak256("Message(uint256 message)");

```solidity
function getMessageHash(uint256 _message) public view returns (bytes32) {
    return _hashTypedDataV4(
        keccak256(
            abi.encode(
                MESSAGE_TYPEHASH,
                Message({message: _message})
            )
        )
    );
}
```

Retrieve the signer with ECDSA.tryRecover and compare it to the actual signer:

```solidity
function getSignerOZ(uint256 digest, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
    (address signer, /* ECDSA.RecoverError recoverError */, /* bytes32 signatureLength */ ) = ECDSA.tryRecover(digest, _v, _r, _s);
    return signer;
}

function verifySignerOZ(
    uint256 message,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    address signer
) public pure returns (bool) {
    address actualSigner = getSignerOZ(getMessageHash(message), _v, _r, _s);
    require(actualSigner == signer);
    return true;
}
```

### Key Features of EIP-712:

1. **Typed Data**: Instead of just signing arbitrary bytes, EIP-712 allows you to sign structured data, which includes type information. This reduces ambiguity and potential errors.

2. **Domain Separation**: EIP-712 uses a domain separator to prevent replay attacks. This means that a signature generated for one context (like one contract) cannot be reused in another.

3. **User-Friendly**: Wallets can present structured data to users for confirmation before they sign, making it easier for users to understand what they are agreeing to.

## Why Use EIP-712?

### Enhanced Security

By providing a structured format for data, EIP-712 reduces the risk of signature replay attacks and other vulnerabilities. For example, if a user signs a message to buy an item in one dApp, that signature can’t be reused maliciously in another dApp.

### Clarity for Users

When users see structured data with clear descriptions, they can understand what they are signing. This transparency builds trust and improves the overall user experience.

### Simplified Development

EIP-712 provides a standardized way to handle message signing. Developers can follow a consistent pattern, reducing bugs and miscommunications in the signature process.

## Integration of EIP-712 

EIP-712 has been integrated in this Airdrop contract to facilitate structured data and meta transactions.

See: (![repository](https://github.com/PaulElisha/Kaia-Airdrop-Distribution))


### Airdrop Distribution Smart Contract
This repository contains a Solidity-based Airdrop Distribution Smart Contract designed to efficiently and securely distribute tokens to multiple recipients. The contract is highly customizable, making it suitable for any token distribution event, including promotional token giveaways, liquidity mining rewards, or airdrop campaigns.

## Features
- Efficient Distribution: Distributes tokens to multiple addresses in a single transaction, reducing gas fees and complexity.
ERC20 Compatible: Supports ERC20 tokens, ensuring compatibility with most tokens on Ethereum and Ethereum-compatible chains like Kaia and others.
- Custom Distribution: Allows the owner to define the amount of tokens each recipient will receive.
Ownership Control: Only the contract owner can initiate token distributions.
- Batch Distribution: Distribute tokens in batches to save on gas fees.
Security-First Design: Includes security features such as reentrancy protection and ownership controls to ensure safe execution.
- Enabling fee payer: A user may not have the gas fees to claim their airdrop so, EIP-712 was integrated into this codebase to ensure someone else pays the gas for the transactions.

## Prerequisites
Solidity: Version 0.8.x or higher
Node.js and npm (to manage dependencies)
Foundry (for deployment and testing)
ERC20 Token Contract: You need a deployed ERC20 token contract to distribute tokens through this Airdrop smart contract.

## Integration Steps

1. Import all neceasary files.

```
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/utils/cryptography/EIP712.sol";
import "@openzeppelin/utils/cryptography/ECDSA.sol";
```
- ERC20: To create a dummy token that would be airdropped to our claimers.
- MerkleProof: An Openzeppelin library used to validate the existence of a claimers data in a large data set without looping through an array.
- EIP -712: To make it compatible for meta-transactions.
- ECDSA: To verify that the signature used to sign the transaction with the claimer's private key is in pair with the public key.

2. State Varibles.
   The following state varibles are required:
    address[] claimers - to store a list of our claimers but it would be inefficient to loop through the array and allow each claimer to make claims of their token so, we would leverage Merkle Trees.

    Merkle trees is a data structure used to store a large number of data set. It uses Merkle Proof to proof that a data is contained in a large number of data set using hashing algorithm.

    bytes32 private immutable i_merkleRoot - The root of the data structure, it's a hash value that represents all the data contained in the set.

    IERC20 private immutable i_token - The token to claim.
    mapping(address claimer => bool) private s_hasClaimed - A data structure used to track the claimers by their addresses in order to prevent multiple claiming and reentrancy.

3. Constructor function - used to set the merkleRoot used to compare our generated root to proof the validity of a data and used to set the token to airdrop.
   
```solidity
    constructor(
        bytes32 merkleRoot,
        address token
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_token = IERC20(token);
    }
```
4. Merkle Tree construction:

The `MakeMerkle` code was imported from `murky` to generate the Merkle Tree. But the tree of data can't be created if we don't have the data.

The `GenerateInput` code was used to generate a json data which is the input in 'target/input.json'. Json data was used as it's more efficient than using an array and since foundry has a standard json library, it was used to generate the json data and sent to 'input.json'.

The input data was brought in to the 'MakeMerkle" script to generate the trees which contains the leafs that was hashed consequently to get the merkle root. 

Note: The addresses to whitelist to stored in the 'whitelist' variable under the 'GenerateInput' script, you can change it to the list of addresses you want to claim your token.

5. Function `claim()`:
```solidity
    function claim(
        address claimer,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        if (s_hasClaimed[claimer]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (
            !_isValidSignature(
                claimer,
                getMessageHash(claimer, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(claimer, amount))) // hash twice to avoid collision
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[claimer] = true;
        emit Claimed(claimer, amount);
        i_token.safeTransfer(claimer, amount);
    }
```

It uses the Merkle proof library to verify the validity of the proof.

`**Tests:**`

See: 
(![test screenshot](air.png))

## Conclusion

EIP-712 is a valuable tool for Ethereum developers looking to enhance security and user experience in their dApps. By signing structured data, you reduce the risk of signature misuse and provide clarity to users about what they are signing. As you build and deploy your applications, consider integrating EIP-712 to ensure a safer and more user-friendly experience.

Now that you understand the basics of EIP-712, you can begin implementing it in your projects. Happy coding!

## Deployment

// Deployed MerkleAirdrop to: 0x090F4dBbE93DE617529Bf189dB611b488bb18bab

// Deployed to: 0x16abE11dC7b33cE03D481c2A20661E70aE2d5c4f
## Installation
Install Dependencies: Ensure that you have installed all required dependencies, including Hardhat or Foundry, by running:

```bash
npm install
```
or

```bash
forge install
Compile the Contract:
```

```bash
npx hardhat compile
```

or

```bash
forge build
Deploy the Contract:
```

```bash
forge script deploy --broadcast
```

Make sure to configure your network settings (e.g., Ethereum, Kaia chain) before running the deployment script.


## Security Considerations
Ensure proper management of the contract owner.
Use trusted sources for deployment and a secure wallet for ownership.
Double-check recipient and amount arrays before distribution to avoid unintended transfers.
License
This project is licensed under the MIT License.