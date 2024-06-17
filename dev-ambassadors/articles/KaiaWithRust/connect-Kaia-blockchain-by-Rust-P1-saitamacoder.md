# Instructions for connecting Kaia blochain with Rust - P1
A common issue I've heard about in Rust is the complexity of implementing code structures that interact with other platforms. This has caused many projects to halt and switch to other programming languages. However, as a builder, I really dislike this, so I will try to provide guides to connect with currently popular platforms, especially in the Blockchain field, including Kaia.

## What is Ethers?
Ethers is the first library used for dApps to interact with the EVM blockchain ecosystem. Initially, it was implemented in JavaScript and has been widely used to interact with the Ethereum blockchain.

## Is there a version of this library for Rust?
Of course, there is! Today, I will guide you on how to interact with and use this powerful library to connect and interact with EVM blockchains, including Kaia.

Let's get started!

## Adding the Library to Your Project
First, to use this library, we can add it to our project as follows:

```toml
    [dependencies]
    ethers = { version = "2.0", features = ["legacy"] }
```

## Importing Your Wallet into the Project

```rust
    // Private key hex (insecure) - Use a secure storage method like a `.env` file
    let private_key_hex = "<PRIVATE_KEY>";

    // Create a LocalWallet from the private key hex with error handling
    let wallet = LocalWallet::from_str(private_key_hex).map_err(|e| Box::new(e) as Box<dyn std::error::Error>)?;
```

This way, we have successfully imported the crypto wallet into the project.

## Wallet Details
Since the wallet type is Wallet<ethers_core::k256::ecdsa::SigningKey>, we can extract components such as signer, address, and chain_id. Here is the code snippet from the library representing the Wallet<ethers_core::k256::ecdsa::SigningKey> object:

```rust
    pub struct Wallet<D: PrehashSigner<(RecoverableSignature, RecoveryId)>> {
        /// The Wallet's private key
        pub(crate) signer: D,
        /// The wallet's address
        pub(crate) address: Address,
        /// The wallet's chain ID (for EIP-155)
        pub(crate) chain_id: u64,
    }
```

## Creating a Global Wallet Variable
Since you will call the wallet many times during the project's build process, I created a global variable to store it:
```rust
    static mut WALLET: Option<Arc<Mutex<LocalWallet>>> = None;
```

Then, initialize it in the same function as the wallet variable:
```rust
    unsafe {
        WALLET = Some(Arc::new(Mutex::new(wallet.clone())));
    }
```

## Accessing the Wallet in a New Function
You can create a new function to call the wallet as follows:

```rust
    let mut address_user = String::new(); // Initialize an empty variable to avoid warnings
    unsafe {
        if let Some(wallet) = &WALLET {
            // Lock the mutex to access the wallet
            if let Ok(guard) = wallet.lock() {
                // Access the wallet's methods
                address_user = guard.address().to_string();
            }
        }
    }
    println!("address: {:?}", address_user.clone());
```

## Calling View Functions in a Smart Contract on Kaia Blockchain
```rust
    let contract_address = "<CONTRACT_ADDRESS>".parse::<Address>()?;
    abigen!(<NAME_CONTRACT>, "<ABI_CONTRACT_PATH>");
    let rpc_url = format!("<RPC_URL>");
    let provider = Provider::<Http>::try_from(rpc_url.as_str())?;
    let provider = Arc::new(provider);
    let contract = <NAME_CONTRACT>::new(contract_address, provider.clone());

    let function_name = "<FUNCTION_NAME>";
    let function_params = ();
    let result: String = contract.method(function_name, function_params)?.call().await?;
    println!("{}", result);
```
Today's session is quite long. I promise to guide you on calling payable functions and signing transactions on the Kaia blockchain in the next session!