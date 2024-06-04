const { ethers, network } = require("hardhat");
const { verify } = require("../utils/verify");

const deploy = async () => {

    const args = ["0xDA8c0A00A372503aa6EC80f9b29Cc97C454bE499"];
    const sendVal = ethers.parseEther("1.0");

    const CoinFlip = await ethers.deployContract("CoinFlip", args);
    console.log("Deploying contract...");
    await CoinFlip.waitForDeployment(6);
    console.log(`Contract Deployed to: ${CoinFlip.target}`)
    console.log(network.config)

    // if (network.config.chainId === 1001 && process.env.KLAYTN_RPC) {
    //     await CoinFlip.waitForDeployment(6);
    //     await verify(CoinFlip.target, args)
    // } else {
    //     console.log("Contract cannot be verified on Hardhat Network")
    // }

    // const flip = await CoinFlip.flip(0, { value: sendVal });
    // await flip.wait(3);
    // console.log(`Flipped!`);
}

deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
