import { ethers } from "hardhat";
async function main() {
    // We get the contract to deploy
    const ContributionSystemFactory = await ethers.deployContract("ContributionSystemFactory");
    await ContributionSystemFactory.waitForDeployment();
    console.log("Deploying ContributionSystemFactory...");
    await ContributionSystemFactory.deployed();
    console.log(
        `Contribution System Factory was deployed to ${ContributionSystemFactory.target}`
      );
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    

    