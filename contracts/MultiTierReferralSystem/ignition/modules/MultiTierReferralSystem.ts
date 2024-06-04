import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MultiTierReferralSystem = buildModule("MultiTierReferralSystem", (m) => {
  const usdcAddress = "0x754288077d0ff82af7a5317c7cb8c444d421d103"; // Example oUSDC (https://klaytnscope.com/token/0x754288077d0ff82af7a5317c7cb8c444d421d103)
  const defaultUpline = "0x0fFee57EAA1026857E381BC51B6832735006fc6a"; // Example Default Upline (Platform Address)
  const multiTierReferralSystem = m.contract("MultiTierReferralSystem", [usdcAddress, defaultUpline]);

  return { multiTierReferralSystem };
});

export default MultiTierReferralSystem;
