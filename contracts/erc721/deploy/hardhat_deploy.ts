import { ethers } from "hardhat";

async function main() {

  const myCollection = await ethers.deployContract("MyCollection");

  await myCollection.waitForDeployment();

  console.log(
    `MyCollection was deployed to ${myCollection.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
