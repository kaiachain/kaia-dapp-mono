import { ethers } from "hardhat";

async function main() {

  const englishAuction = await ethers.deployContract("EnglishAuction");

  await englishAuction.waitForDeployment();

  console.log(
    `EnglishAuction was deployed to ${englishAuction.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
