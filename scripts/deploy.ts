import { ethers, upgrades } from "hardhat";

async function main() {
  console.log("🚀 Deploying BaseOmniVaultAI on Base network...");

  // دریافت اطلاعات از متغیرهای محیطی یا مقادیر پیش‌فرض
  const [deployer] = await ethers.getSigners();
  const adminAddress = process.env.ADMIN_ADDRESS || deployer.address;
  const timelockAddress = process.env.TIMELOCK_ADDRESS || deployer.address;
  const oracleAddress = process.env.ORACLE_ADDRESS || "0x71041dddad3595f9ce4bcd3c09107954b377abca"; // Chainlink ETH/USD on Base Mainnet
  const entryPointAddress = process.env.ENTRY_POINT_ADDRESS || "0x5FF137D4b0FDCD42Dca39c72516Le33A032Bd145"; // ERC-4337 EntryPoint v0.6
  const recoveryThreshold = 2; // تعداد تاییدیه لازم برای بازیابی اجتماعی

  const BaseOmniVaultAI = await ethers.getContractFactory("BaseOmniVaultAI");

  // دیپلوی قرارداد به صورت UUPS Proxy
  const vault = await upgrades.deployProxy(
    BaseOmniVaultAI,
    [adminAddress, timelockAddress, oracleAddress, entryPointAddress, recoveryThreshold],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );

  await vault.waitForDeployment();
  const proxyAddress = await vault.getAddress();

  console.log(`✅ BaseOmniVaultAI Proxy successfully deployed at: ${proxyAddress}`);
  console.log(`🛡️ Initialized with Admin: ${adminAddress}`);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});