# Motivation

Let’s say we all own a company, or a liquidity pool, that earns a stablecoin DAI periodically. The stablecoin DAI is the asset in this case.

One inefficient way we could distribute the earnings is to push out DAI to each of the holders of the company on a pro-rata basis. But this would be extremely expensive gas wise. 

Similarly, if we were to update everyone’s balance inside a smart contract, that would be expensive too.

Instead, this is how the workflow would work with ERC4626.

Let’s say you and nine friends get together and each deposit 10 DAI each into the ERC4626 vault (100 DAI total). You get back one share.

So far so good. Now your company earns 10 more DAI, so the total DAI inside the vault is now 110 DAI.

When you trade your share back for your part of the DAI, you don’t get 10 DAI back, but 11.

Now there is 99 DAI in the vault, but 9 people to share it among. If they were to each withdraw, they would get 11 DAI each.

Note how efficient this is. When someone makes a trade, instead of updating everyones shares one-by-one, only the total supply of shares and the amount of assets in the contract changes.

ERC4626 does not have to be used in this manner. You can have an arbitrary mathematical formula that determines the relationship between shares and assets. For example, you could say every time someone withdraws the asset, they also have to pay some sort of a tax that depends on the block timestamp or something like that.

The ERC 4626 standard provides a gas efficient means for executing very common DeFi accounting practices.