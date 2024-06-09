const { expect } = require("chai");
const { ethers } = require("ethers");

describe("AdvancedStorage", function () {
  
    it("Check vault manager", async function () {
        // Make sure contract is compiled and artifacts are generated
        const advancedStorageMetadata = JSON.parse(await remix.call('fileManager', 'getFile', 'artifacts/AdvancedStorage.json'))
        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
        const signerAddress = await signer.getAddress();
        let AdvancedStorage = new ethers.ContractFactory(advancedStorageMetadata.abi, advancedStorageMetadata.data.bytecode.object, signer);
        let advancedStorage = await AdvancedStorage.deploy();
        console.log('storage contract Address: ' + advancedStorage.address);
        await advancedStorage.deployed();
        expect((await advancedStorage.vaultManager()).toString()).to.equal(signerAddress);
    });

    it("Check set initial investment", async function () {
        const advancedStorageMetadata = JSON.parse(await remix.call('fileManager', 'getFile', 'artifacts/AdvancedStorage.json'));
        const customerIdentityCardMetadata = JSON.parse(await remix.call('fileManager', 'getFile', 'artifacts/CustomerIdentityCard.json'));
        const provider = new ethers.providers.Web3Provider(web3Provider)
        const signer = provider.getSigner();
        const acc2 = await provider.getSigner(1).getAddress();
        let AdvancedStorage = new ethers.ContractFactory(advancedStorageMetadata.abi, advancedStorageMetadata.data.bytecode.object, signer);
        let advancedStorage = await AdvancedStorage.deploy();
        console.log('storage contract Address: ' + advancedStorage.address);
        await advancedStorage.deployed();
        await advancedStorage.setInitialInvestmentVault(10, 5, acc2.toString());
        const customerIdentityCardAddress = (await advancedStorage.retrieveInvestmentVault())[3];
        const customerIdentityCard = new ethers.Contract(customerIdentityCardAddress, customerIdentityCardMetadata.abi, signer);
        expect((await advancedStorage.retrieveInvestmentVault())[1].toNumber()).to.equal(5);
        expect((await advancedStorage.retrieveInvestmentVault())[2]).to.equal(true);
        expect(customerIdentityCardAddress).to.equal(customerIdentityCard.address);
    });

    it("Check customer information", async function() {
        const advancedStorageMetadata = JSON.parse(await remix.call('fileManager', 'getFile', 'artifacts/AdvancedStorage.json'));
        const customerIdentityCardMetadata = JSON.parse(await remix.call('fileManager', 'getFile', 'artifacts/CustomerIdentityCard.json'));
        const provider = new ethers.providers.Web3Provider(web3Provider)
        const signer = provider.getSigner();
        const acc2 = await provider.getSigner(1).getAddress();
        let AdvancedStorage = new ethers.ContractFactory(advancedStorageMetadata.abi, advancedStorageMetadata.data.bytecode.object, signer);
        let advancedStorage = await AdvancedStorage.deploy();
        console.log('storage contract Address: ' + advancedStorage.address);
        await advancedStorage.deployed();
        await advancedStorage.setInitialInvestmentVault(10, 5, acc2.toString());
        const customerIdentityCardAddress = (await advancedStorage.retrieveInvestmentVault())[3];
        const customerIdentityCard = new ethers.Contract(customerIdentityCardAddress, customerIdentityCardMetadata.abi, signer);
        expect(await customerIdentityCard.customer()).to.equal(acc2);
    });
});