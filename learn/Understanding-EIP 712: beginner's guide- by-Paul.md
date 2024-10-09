# Understanding EIP-712: A Beginner's Guide to Typed Data Signing in Ethereum

Oftentimes, User Interaction issues might arise when it comes to signing messages and transactions securely. This is where **EIP-712** comes into play. 


In this article, we'll explore what **EIP-712** is, why it matters, and how to implement it in your dApps. 

## Prerequisites:
There is no prerequisite to understand the EIP712 Signature standard.

Just take a sit back and keep reading.

## What is EIP-712?

EIP-712, or Ethereum Improvement Proposal 712, is a standard for hashing, structuring and signing typed structured data in Ethereum, improving User Interaction, readability and ensuring specificity to certain contracts. The primary goal of EIP-712 is to provide a way to prevent misuse of signatures by allowing developers to define a clear structure for the data being signed, which adds an extra layer of security.

Before the EIP712 standard, we had the EIP191 standard used to facilitate already made signatures or sponsored transactions - that is, you can sign a message and approve someone to send the transaction using their gas fees.

**This standard has a format for signed data:**

0x19 <1 byte version> <version specific data> <data to sign>
0x19 Prefix: Indicates that the data is a signature.
1-byte Version: Defines the signed data version.
0x00: Data with an intended validator.
0x01: Structured data, commonly used in smart contract and associated with EIP 712.
0x45: Personal signed messages.
Version Specific Data: For version 0x01 which is the commonly used signed data version, there is specific data associated with this version.
Data to Sign: The transaction message we want to sign.
How to setup EIP 191 in your smart contract:

```solidity
function getSigner191(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
    // Prepare data for hashing
    bytes1 prefix = bytes1(0x19);
    bytes1 eip191Version = bytes1(0);
    address intendedValidatorAddress = address(this);
    bytes32 applicationSpecificData = bytes32(message);

    // Standardized message format
    bytes32 hashedMessage = keccak256(abi.encodePacked(prefix, eip191Version, intendedValidatorAddress, applicationSpecificData));

    address signer = ecrecover(hashedMessage, _v, _r, _s);
    return signer;
}
```
Similarly to EIP 191, the EIP 712 signature standard has a format that ensures structuring of signed data:

0x19 0x01 <domainSeparator> <hashStruct(message)>

Domain Separator: Version-specific data.
hashStruct(message): The hash of the structured message you want to sign.
To define the domain separator, we first declare a domain separator struct and its type hash:
struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
};

bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

First, define the message struct and its type hash:
struct Message {
    uint256 number;
};

bytes32 public constant MESSAGE_TYPEHASH = keccak256("Message(uint256 number)");

Then encode and hash them together:
bytes32 hashedMessage = keccak256(abi.encode(MESSAGE_TYPEHASH, Message({ number: message })));

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

**Note:** 
For usage in a codebase, see (repository)[https://github.com/PaulElisha/Kaia-Airdrop-Distribution]
## Conclusion

EIP-712 is a valuable tool for Ethereum developers looking to enhance security and user experience in their dApps. By signing structured data, you reduce the risk of signature misuse and provide clarity to users about what they are signing. As you build and deploy your applications, consider integrating EIP-712 to ensure a safer and more user-friendly experience.

Now that you understand the basics of EIP-712, you can begin implementing it in your projects. Happy coding!

