import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { parseUnits } from "viem";
  
describe("Multi-tier Referral system", function () {
  async function deployMultiTierReferralSystem() {
    const [deployer, defaultUpline, account1, account2] = await hre.viem.getWalletClients();

    const usdc = await hre.viem.deployContract("ExampleUSDC", []);
    const multiTierReferralSystem = await hre.viem.deployContract("MultiTierReferralSystem", [usdc.address, defaultUpline.account.address]);

    const publicClient = await hre.viem.getPublicClient();

    return {
      deployer,
      defaultUpline,
      account1,
      account2,
      usdc,
      multiTierReferralSystem,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("Name & Symbol", async function () {
      const { multiTierReferralSystem } = await loadFixture(deployMultiTierReferralSystem);

      expect(await multiTierReferralSystem.read.name()).to.equal("Multi-Tier Referral System");
      expect(await multiTierReferralSystem.read.symbol()).to.equal("MTRS");
    });

    it("Default Upline & Initial Supply", async function () {
      const { multiTierReferralSystem, defaultUpline } = await loadFixture(deployMultiTierReferralSystem);

      // tokenId 1-10 is defaultUpline Account
      const tokenId = await multiTierReferralSystem.read.lastUplineTokenId();
      expect((await multiTierReferralSystem.read.ownerOf([tokenId])).toLowerCase()).to.equal(defaultUpline.account.address);
      expect(await multiTierReferralSystem.read.totalSupply()).to.equal(BigInt(10));
    });
  });

  describe("Registration", function () {
    it("Registration with Account 1 & Account 2", async function () {
      const { usdc, multiTierReferralSystem, defaultUpline, account1, account2 } = await loadFixture(deployMultiTierReferralSystem);

      // Check Balance USDC is 0
      expect(await usdc.read.balanceOf([defaultUpline.account.address])).to.equal(BigInt(0));
      expect(await usdc.read.balanceOf([account1.account.address])).to.equal(BigInt(0));
      expect(await usdc.read.balanceOf([account2.account.address])).to.equal(BigInt(0));

      // Send 100 USDC to Account 1 & Account 2
      const decimalUSDC = Number(await usdc.read.decimals());
      const amount = parseUnits("100", decimalUSDC);
      await usdc.write.transfer([account1.account.address, amount]);
      await usdc.write.transfer([account2.account.address, amount]);
      expect(await usdc.read.balanceOf([account1.account.address])).to.equal(amount);
      expect(await usdc.read.balanceOf([account2.account.address])).to.equal(amount);

      // Registration Account 1 with Default Upline
      await usdc.write.approve([multiTierReferralSystem.address, amount], {
          account: account1.account
      });
      expect(await usdc.read.allowance([account1.account.address, multiTierReferralSystem.address])).to.equal(amount);
      await multiTierReferralSystem.write.registration([
          BigInt(0), // Set 0 if use default upline
          BigInt(11) // new tokenId
      ], {
          account: account1.account
      });
      expect(await usdc.read.balanceOf([defaultUpline.account.address])).to.equal(amount); // tokenId 1-10 distribute to defaultUpline Account -> total 100 USDC

      // Registration Account 2 with Account 1 (tokenId 11)
      await usdc.write.approve([multiTierReferralSystem.address, amount], {
          account: account2.account
      });
      expect(await usdc.read.allowance([account2.account.address, multiTierReferralSystem.address])).to.equal(amount);
      expect((await multiTierReferralSystem.read.ownerOf([BigInt(11)])).toLowerCase()).to.equal(account1.account.address);
      await multiTierReferralSystem.write.registration([
          BigInt(11), // Set 11 if use Upline Account 1
          BigInt(12) // new tokenId
      ], {
          account: account2.account
      });
      expect(await usdc.read.balanceOf([defaultUpline.account.address]))
      .to.equal((amount + parseUnits("90", decimalUSDC))); // amount + (tokenId 2-10 distribute to defaultUpline Account) -> total 190 USDC
      expect(await usdc.read.balanceOf([account1.account.address])).to.equal(parseUnits("10", decimalUSDC)); // total 10 USDC
    });
  });
});
  