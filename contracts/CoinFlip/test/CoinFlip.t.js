const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("CoinFlip", () => {
    let CoinFlip;
    const val = ethers.parseEther("1");
    const args = "0x6B4c0b11bd7fE1E9e9a69297347cFDccA416dF5F"

    beforeEach(async () => {
        CoinFlip = await ethers.deployContract("CoinFlip", [args]);
    })

    describe("flip", async () => {
        it("should revert if value is less than entry fees", async () => {
            const val = ethers.parseEther("0.1");
            expect(CoinFlip.flip(0, { value: val })).to.be.revertedWith("Insufficient Entry Fund");
        });

        it("should equal entry fees", async () => {
            const entryfees = await CoinFlip.s_entryFees();
            assert.equal(entryfees, val);
        })
    });
});
