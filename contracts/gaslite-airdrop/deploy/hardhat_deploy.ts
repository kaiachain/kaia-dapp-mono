import { ethers } from "hardhat";

async function main() {

  const gasliteAirdrop = await ethers.deployContract("GasliteDrop");

  await gasliteAirdrop.waitForDeployment();

  console.log(
    `GasliteDrop was deployed to ${gasliteAirdrop.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
