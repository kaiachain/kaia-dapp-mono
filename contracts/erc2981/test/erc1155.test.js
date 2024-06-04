const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC1155Example", function () {

    it("Should deploy", async function () {
        const Example = await ethers.getContractFactory("ERC1155Example");
        this.example = await Example.deploy();
        await this.example.deployed();

        // check that the contract indicates it supports royalties
        expect(await this.example.supportsInterface("0x2a55205a")).to.equal(true);
    });

    it("Should mint", async function () {
        const [owner, wallet] = await ethers.getSigners();
        const tokenId = 420;
        const tokenAmount = 1;

        await expect(this.example.mint(wallet.address, tokenId, tokenAmount, "0x", { from: owner.address }))
            .to.emit(this.example, 'TransferSingle')
            .withArgs(owner.address, ethers.constants.AddressZero, wallet.address, tokenId, tokenAmount);
    });

    it("Check global royalty", async function () {
        const [owner] = await ethers.getSigners();

        // "buy" an NFT for 100 Eth, to make percentage calculation easy
        const salePrice = ethers.utils.parseEther("100");
        // get the royalty information from the contract with the sale price
        let [reciever, amount] = await this.example.royaltyInfo(420, salePrice);

        // the owner should be getting 5% of the sale
        expect(reciever).to.equal(owner.address);
        expect(amount).to.equal(ethers.utils.parseEther("5"));
    });
});