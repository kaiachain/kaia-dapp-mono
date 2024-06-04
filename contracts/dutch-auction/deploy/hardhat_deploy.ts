import { ethers } from "hardhat";

async function main() {

  const dutchAuction = await ethers.deployContract("DutchAuction");

  await dutchAuction.waitForDeployment();

  console.log(
    `DutchAuction was deployed to ${dutchAuction.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
