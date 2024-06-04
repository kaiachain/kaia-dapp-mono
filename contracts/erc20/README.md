# Guides

## ERC20 smart contract
1. 

## Remix
1. Copy and paste the `MyToken.sol` file into the `contracts` folder on Remix
2. Copy and paste the MyToken_remix_test.sol file into `test` folder
3. Compile and run test
4. Deploy using Remix `Deploy` tab

## Hardhat
1. Follow Hardhat documentation to set up your project
> It is highly recommended that you set up your project with Typescript

Project structure
```bash
project-repo  
├── contracts/
├── scripts/
├── test/
└── hardhat.config.js
```

2. Copy and paste the `MyToken.sol` file into the `contracts` folder
3. Copy and paste the MyToken_hardhat_test.ts file into the `test` folder
4. Copy the content of the `hardhat.config.js` file below and set your vars (refer to [Hardhat Managing Configuration variables](https://hardhat.org/hardhat-runner/docs/guides/configuration-variables#managing-configuration-variables))
```js
import { HardhatUserConfig } from "hardhat/config";
const { vars } = require("hardhat/config");
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  defaultNetwork: "cypress",
  networks: {
    hardhat: {
    },
    // klaytn mainnet
    cypress: {
      url: "https://rpc.ankr.com/klaytn",
      chainId: 8217,
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      accounts: [vars.get("PRIVATE_KEY")]
    },
    // klaytn testnet
    baobab: {
      url: "https://rpc.ankr.com/klaytn_testnet",
      chainId: 1001,
      gas: "auto",
      gasPrice: "auto",
      gasMultiplier: 1,
      accounts: [vars.get("PRIVATE_KEY")]
    }
  },
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
};

export default config;
```
5. Follow Hardhat documentation on [Deployment](https://hardhat.org/hardhat-runner/docs/guides/deploying) to deploy your contract to Baobab (testnet) or Cypress (mainnet).

## Foundry
1. Follow Foundry documentation to set up your project

Project structure
```bash
project-repo
├── README.md
├── foundry.toml
├── lib
├── script
├── src
└── test
```
2. 