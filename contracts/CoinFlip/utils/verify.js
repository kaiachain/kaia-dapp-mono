import run from "hardhat"

const verify = async (contractAddress, args) => {
    console.log("Verifying contract....")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArgs: args
        })
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Already verified...!")
        } else {
            console.log(error);
        }
    }
}

module.exports = {
    verify
}