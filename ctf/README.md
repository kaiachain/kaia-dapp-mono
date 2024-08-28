# KSL Castle Raids

## Briefing
Welcome folks to KSL catsle raids. You will be our main attack force to raid the enemy castles. You can read the detail rules below.

## Rules
Below is the 3 main attack plans, graded based on difficulty.
| Category | Contract |
| --- | --- |
| `Easy` | `RaidTreasury.sol` |
| `Medium` | `RaidGemVault.sol` |
| `Hard` | `BanditFort.sol` |

### `RaidTreasury.sol`
For this attack plan, you need to formulate an attack angle for the smart contract and write your own attack script. If you can drain the entire balance of `GOLD` tokens inside the smart contract, you have successfully raided the enemy treasuries. Look carefully at the contract's code.


### `RaidGemVault.sol`
For this attack plan, you need to formulate an attack angle for the smart contract and write your own attack script. Most importantly, you need to unlock the vault. If you can drain the `GEM` NFT inside the smart contract, you have successfully raided the enemy vault.

### `BanditFort.sol`
For this attack plan, you need to formulate an attack angle for the smart contract and write your own attack script. If you can break the contract so that nobody else can be `banditLord`, you have successfully eliminated an enemy clan.

### `CastleMap.sol`
To make it easy to find, our scouts have reported back with a smart contract storing addresses of all the trasuries, vaults and forts.

### ABIs
Included in this attack kit, you can find the relevant ABIs to be used in your attack.

## Prizes
After completion, ask one of the Kaia team members at the KSL for your rewards.

## Submission guidelines
1. First, please register by opening a PR adding a folder with the same name as your github handle in the [`submissions` folder](/ctf/submissions/) We have included an [example](/ctf/submissions/zxstim/) inside for your reference. Your folder structure would look like this:
```bash
submissions/
└── your-name/
    └── your-name.md
```
Inside your `your-name.md` file, add the title to be:
```
# KSL Castle Raids
```
You will use this file for your own submission later.
2. Review the attack kit, select one address for each plan from `CastleMap` contract then attack.  
3. Collect the `GOLD` token and the `GEM` NFT. For the last challenge, you need to break the contract.  
4. Add the following to `your-name.md`:
```
My address: 0xabc...
My attacked RaidTreasury: 0xabc...
My attacked GemVault: 0xabc...
My attacked BanditFort: 0xabc...
The broken banditLord: 0xabc...
``` 
5. Open a PR and call over a Kaia team member to review your work.
6. If accepted, we will give you the rewards.

## Castle map address

Deployment logs:
```bash
✅  [Success]Hash: 0xf1c9ea7a6366b99ab8a03375c3419494a9f690f3b5815ac439c36f6610339886
Contract Address: 0x95CE14EE82410C4a7296205e0c663969703Dc857
Block: 163078779
Paid: 0.0178661725 ETH (649679 gas * 27.5 gwei)
```

## GOLD token address

Deployment logs:
```bash
✅  [Success]Hash: 0xaadb9b962d9b3e485f0d129afadac6224b6fb497f1418f4cbfd257d78be39ef3
Contract Address: 0x32Bf51fa408A0ee9B7A414C6A793760CaF086118
Block: 163091994
Paid: 0.042233015 ETH (1535746 gas * 27.5 gwei)
```

## Diamond Gem Stone (GEM) NFT address

Deployment logs:
```bash
✅  [Success]Hash: 0x2431bde7c77b4a7c530e04629acde754c06703832c85df587ff5756c42c626f8
Contract Address: 0x7bE02dECC3DC3BE771d851fcF457Bd9bAA99010A
Block: 163073556
Paid: 0.14547203 ETH (2644946 gas * 55 gwei)
```
