# Instructions for interacting with Kaia using Rust with Alloy library
A common issue I've heard about in Rust is the complexity of implementing code structures that interact with other platforms. This has caused many projects to halt and switch to other programming languages. However, as a builder, I really dislike this, so I will try to provide guides to connect with currently popular platforms, especially in the Blockchain field, including Kaia.

## Transition from Ethers to Alloy
Ethers has been the go-to library for dApps to interact with the EVM blockchain ecosystem, initially implemented in JavaScript and widely used to interact with the Kaia blockchain. However, the landscape is evolving, and Alloy is emerging as a powerful library for Rust developers to interact with Kaia.

## What is Alloy?
Alloy is a Rust library designed to simplify interactions with Kaia and other EVM-compatible blockchains. It offers a robust set of tools for managing wallets, contracts, and transactions in a more Rust-centric way.

Let's get started!

## Adding the Alloy Library to Your Project
First, to use this library, we can add it to our project as follows:
```toml
    [dependencies]
    alloy = "0.1"
    tokio = { version = "1", features = ["full"] }
    eyre = "0.6"
    serde = { version = "1", features = ["derive"] }
    serde_json = "1.0"
```

## Importing the Alloy Library
```rust
    use alloy::{
        contract::{ContractInstance, Interface}, 
        dyn_abi::DynSolValue, 
        network::{Ethereum, TransactionBuilder}, 
        primitives::{address, U256}, 
        providers::{Provider, ProviderBuilder}, 
        rpc::types::TransactionRequest, 
        transports::http::{Client, Http}
    };
    use eyre::Result;
    use serde_json;
```

## Importing Your Wallet into the Project
```rust
    use alloy::signers::local::PrivateKeySigner;

    let signer: PrivateKeySigner = "<YOUR-PRIVATEKEY>".parse().expect("should parse private key");
    let wallet = EthereumWallet::from(signer);
```
This way, we have successfully imported the crypto wallet into the project.

## Connecting to the Smart Contract
```rust
    let contract_address = address!("447E5c95E9e81f0bE6dAcd5c25D3A814D2dA0d41");

    // Get the contract ABI.
    let path = std::env::current_dir()?.join("abi/Counter.json");

    // Read the artifact which contains abi, bytecode, deployedBytecode and metadata.
    let artifact = std::fs::read(path).expect("Failed to read artifact");
    let json: serde_json::Value = serde_json::from_slice(&artifact)?;

    // Get abi from the artifact.
    let abi_value = json.get("abi").expect("Failed to get ABI from artifact");
    let abi = serde_json::from_str(&abi_value.to_string())?;

    // Create a new ContractInstance of the Counter contract from the abi
    let contract: ContractInstance<Http<Client>, _, Ethereum> =
        ContractInstance::new(contract_address, provider.clone(), Interface::new(abi));
```

## Creating a Provider for your wallet on Kaia Blockchain
```rust
    let provider_url = "https://public-en-baobab.klaytn.net".parse()?;
    let provider = ProviderBuilder::new().wallet(wallet.clone()).on_http(provider_url);
```

## Calling Functions in a Smart Contract on Kaia Blockchain
```rust
    // Set the number to 42.
    let number_value = DynSolValue::from(U256::from(42));
    let tx_hash = contract.function("setNumber", &[number_value])?.send().await?.watch().await?;

    println!("Set number to 42: {tx_hash}");

    // Increment the number to 43.
    let tx_hash = contract.function("increment", &[])?.send().await?.watch().await?;

    println!("Incremented number: {tx_hash}");
```

## Retrieving the Number from the Smart Contract
```rust
    // Retrieve the number, which should be 43.
    let number_value = contract.function("number", &[])?.call().await?;
    let number = number_value.first().unwrap().as_uint().unwrap().0;
    assert_eq!(U256::from(43), number);

    println!("Retrieved number: {number}");
```

Thank you for reading this article. I hope you find it helpful.