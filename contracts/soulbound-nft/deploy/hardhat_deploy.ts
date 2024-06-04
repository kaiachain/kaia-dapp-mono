import { ethers } from "hardhat";

async function main() {

  const soulboundNFT = await ethers.deployContract("SoulboundNFT");

  await soulboundNFT.waitForDeployment();

  console.log(
    `SoulboundNFT was deployed to ${soulboundNFT.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
