# ERC4626: Tokenized Vault Contract Simplified 

## Introduction

One of the common problems in DeFi is the difference in the smart contract implementation of yield-bearing protocols. For instance, Yearn allows you to deposit tokens into a vault and earn a yield on the tokens while they are deposited. Aave and Compound do similar things with their lending and borrowing contracts. The common thing about all these protocols is you will receive a vault token in return which acts as a certificate of ownership. For as long as the asset token is staked, your vault token compounds, and when you want to receive the asset staked, you exchange your certificate of ownership which is represented as a fungible token. This doesn’t make DeFi composable and everyone has to learn the implementation of various protocols to interact with them because there is no unifying standard. Okay, let me explain what a yield bearing vault is.

## WHAT IS A VAULT?

Vaults are smart contracts and their purpose is to accrue yield as long as you have your tokens locked. Each vault can have its strategy for accruing yield which may include: providing liquidity or lending the asset token.

Example: If you deposit DAI into a vault and receive vDAI and over time as your DAI accrues value, you will receive more vDAI. The vDAI is a yield-bearing token representing a fractional ownership of the overall asset locked in the pool. If the value of the asset token grows then the value of your yield-bearing token grows because you own a stake in the pool.

The problem is that there is no unifying standard and it’s very hard to make DeFi composable if these protocols don’t fit together. That is why we have ERC4626.

## ERC4626 INTERFACE:
ERC4626 is a standard interface of what every tokenized vault should adhere to.

1. It is an ERC20/KIP7 token by default.
2. It implements other functions thereby extending it’s functionality.

ERC4626 Interface implements the following ERC20/KIP7 Interface.

```solidity
function name() public view returns (string)
function symbol() public view returns (string)
function decimals() public view returns (uint8)
function totalSupply() public view returns (uint256)
function balanceOf(address _owner) public view returns (uint256 balance)
function transfer(address _to, uint256 _value) public returns (bool success)
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
function approve(address _spender, uint256 _value) public returns (bool success)
function allowance(address _owner, address _spender) public view returns (uint256 remaining) 
```

And the following functions extends its functionality:

```solidity
function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

       
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares)
}

function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); 

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender];

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);  

}

function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply;

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
}

function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
}

function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
}

function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
}

function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
}

function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares)
}

function asset() public view virtual returns(address) {
        return asset;
}
```

Asset is the underlying token that can only be sent into the vault.

Total Asset is the total amount accrued plus the profit gotten after applying some investment strategy, it’s different from total supply.

Total supply is the total amount staked into the vault contract.

Preview functions do an on-chain simulation to know the total amount to either deposit, withdraw, redeem, or mint.

Though for a full ERC4626, some amounts are charged as fees for using the vault.

OpenZeppelin implements the fee logic into their smart contract, click ERC4626 to view its implementation.

## VAULT MATH:
How does the vault contract calculate the amount of shares to mint to the user?

The picture below shows how the shares are calculated when a user deposits into the vault.

A — Amount to deposit.

B — The balance of the total amount of assets plus the profit made in the vault.

S — The shares to mint is what we want to solve for.

T — Total supply of the vault token which represents the shares to mint.

The total amount of shares to mint has to be proportional to the increase in the total assets in the vault. So if user A deposits 10 tokens, the shares to mint have to be proportional to the amount that increased the initial balance of the vault. This means a 10 DAI deposit will get 10 vDAI minted.

When a user deposits x amount, it is added to the balance of the total supply and the total assets. So; (X + B)/B(Initial balance) = (S + T)/T. Then we will find the subject of the formula.

The inverse of the deposit calculation applies when a user wants to withdraw.

## BUILDING A VAULT CONTRACT:
### Prerequisites:

. Knowledge of Hardhat.

. Basic understanding of smart contract writing in Solidity.

### Step 1:

Create a smart contract called TokenizedVault.

Create a constructor that inherits from ERC4626Fees.

The address of the asset that the vault contract accepts is passed to the constructor.

To create a vault token, we don’t need to import ERC20 since it’s inherited by ERC4626Fees.

```solidity
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.22;

import "./ERC4626Fees.sol";

contract TokenizedVault is ERC4626Fees {
    address payable public vaultOwner;
    uint256 entryFeeBasisPoints;

    constructor(IERC20 _asset, uint256 basisPointsFees) ERC4626(_asset) ERC20("Vault Ocean Token", "vOCT") {
        vaultOwner = payable(msg.sender);
        entryFeeBasisPoints = basisPointsFees;
    }

}
```

### Step 2:

Copy and paste the functions below.

```solidity
function deposit(uint256 assets, address receiver) public override returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        afterDeposit(assets);

        return shares;
    }

    function mint(uint256 shares, address receiver) public override returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        afterDeposit(assets);

        return assets;
    }

    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        beforeWithdraw(assets,  shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        beforeWithdraw(assets,  shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    function _entryFeeBasisPoints() internal view override returns (uint256) {
        return entryFeeBasisPoints;
    }

    function _entryFeeRecipient() internal view override returns (address) {
        return vaultOwner;
    }

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets) internal virtual {
        uint256 interest = assets/10;
        SafeERC20.safetransferFrom(IERC20(asset()), vaultOwner, address(this), interest);
    }
```

Deposit: It takes two parameters, the amount of asset to send and the address of the receiver of the share token which is the address of the sender.

It checks the maximum amount that can be deposited into the vault and it reverts if the amount exceeds it.

It previewDeposit to calculate the shares to be minted.

It calls the internal deposit function which calls the mint function to mint some amount of shares to the receiver and takes the asset sent into the vault.

Withdraw: It takes three parameters, the amount to withdraw, the address of the receiver of the asset, and the address of the owner. In this case, since the owner of the asset is the receiver then you pass in the same address.

The difference between withdraw and redeem is that withdraw takes some amount to get exact shares and redeem takes exact shares to get some assets.

Mint: It takes two parameters, the amount of shares to mint and the receiver.

Note: The beforeWithdraw and afterDeposit hooks are used to hook into the strategy contract you want to implement. That’s where you can interact with the protocol you want to supply liquidity to for profit. It’s implemented by Solmate, not OpenZeppelin.

## VAULT STRATEGY:
Vault strategy is the strategy applied to bring profit to the vault and increase the total assets in the vault. The strategy can be in the same contract or a different contract, but it is unique to different protocols and this article doesn’t cover that. You may need to do your research about how to hook a strategy into the vault contract. Other protocols like the fei protocol implemented a vault router that routes users from one vault to another of the same underlying token. It all depends on your design and strategy.

### SECURITY CONSIDERATIONS — ERC4626 Vault Contracts:
When implementing ERC4626 vault contracts, it’s essential to address potential security risks to ensure the safety and reliability of the protocol. Below are some key security considerations:

1. Inflation Risk
Description: Inflation risk occurs when the issuance of vault tokens (shares) increases disproportionately compared to the underlying assets, leading to a dilution of value for existing token holders.
Mitigation: Implement strict controls on the minting process to ensure shares are issued only when corresponding assets are deposited. Regular audits and monitoring of the vault’s total assets versus total shares can help detect and prevent inflationary scenarios.
1. Smart Contract Vulnerabilities
Description: Smart contracts can have bugs or vulnerabilities that could be exploited by malicious actors.
Mitigation: Conduct thorough code audits by reputable third-party security firms. Use established libraries and frameworks like OpenZeppelin to minimize the risk of vulnerabilities. Implement bug bounty programs to incentivize the community to find and report bugs.
1. Front-Running Attacks
Description: Front-running occurs when a malicious actor observes pending transactions and takes advantage of this knowledge to execute a transaction ahead of the observed one.
Mitigation: Implement transaction ordering mechanisms such as committing transactions in batches or using cryptographic techniques to hide transaction details until they are mined.

## CONCLUSION:
The ERC4626 contract provides a standard API to solve the DeFi composability problem. It increases interoperability and it reduces development time integrating other protocols.