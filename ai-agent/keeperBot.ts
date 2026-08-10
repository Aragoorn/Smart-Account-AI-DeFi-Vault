import { ethers } from "ethers";
import { wallet, VAULT_CONTRACT_ADDRESS } from "./config";
import { analyzeMarketAndDecide } from "./aiAnalyzer";

// ABI مختصر برای تابع executeTrade در قرارداد شما
const VAULT_ABI = [
  "function executeTrade(address target, bytes calldata data, uint256 value) external payable"
];

async function runKeeperLoop() {
  const vaultContract = new ethers.Contract(VAULT_CONTRACT_ADDRESS, VAULT_ABI, wallet);

  console.log("🚀 Base Omni Vault AI Keeper started successfully...");

  setInterval(async () => {
    try {
      // ۱. دریافت تصمیم از هوش مصنوعی
      const decision = await analyzeMarketAndDecide();

      if (decision.shouldTrade) {
        console.log(`💡 AI Triggering Trade: ${decision.reason}`);

        // ۲. ارسال تراکنش به قرارداد هوشمند روی شبکه Base
        const tx = await vaultContract.executeTrade(
          decision.target,
          decision.data,
          decision.value
        );

        console.log(`🔗 Transaction sent! Hash: ${tx.hash}`);
        const receipt = await tx.wait();
        console.log(`✅ Transaction confirmed in block ${receipt?.blockNumber}`);
      } else {
        console.log(`🛡️ AI Policy Check passed: ${decision.reason}`);
      }
    } catch (error) {
      console.error("❌ Error in AI Keeper loop:", error);
    }
  }, 60000); // بررسی و اجرا در هر ۶۰ ثانیه
}

runKeeperLoop();