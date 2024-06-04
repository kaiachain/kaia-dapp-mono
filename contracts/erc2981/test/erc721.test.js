const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721Example", function () {
    let example;

    it("Should deploy", async function () {
        const Example = await ethers.getContractFactory("ERC721Example");
        example = await Example.deploy();
        await example.deployed();

        expect(await example.name()).to.equal("Name");
        expect(await example.symbol()).to.equal("Symbol");
        // check that the contract indicates it supports royalties
        expect(await example.supportsInterface("0x2a55205a")).to.equal(true);
    });

    it("Should mint", async function () {
        const [_owner, wallet] = await ethers.getSigners();
        const tokenId = 420;

        await expect(example.mint(wallet.address, tokenId))
            .to.emit(example, 'Transfer')
            .withArgs(ethers.constants.AddressZero, wallet.address, tokenId);
    });

    it("Check global royalty", async function () {
        const [owner] = await ethers.getSigners();

        // "buy" an NFT for 100 Eth, to make percentage calculation easy
        const salePrice = ethers.utils.parseEther("100");
        // get the royalty information from the contract with the sale price
        let [reciever, amount] = await example.royaltyInfo(420, salePrice);

        // the owner should be getting 5% of the sale
        expect(reciever).to.equal(owner.address);
        expect(amount).to.equal(ethers.utils.parseEther("5"));
    });
});