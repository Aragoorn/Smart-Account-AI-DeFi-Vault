import { ethers } from "ethers";

// تنظیمات شبکه Base
export const RPC_URL = process.env.BASE_RPC_URL || "https://mainnet.base.org"; // یا base-sepolia
export const PRIVATE_KEY = process.env.AI_AGENT_PRIVATE_KEY || "YOUR_AI_AGENT_PRIVATE_KEY";
export const VAULT_CONTRACT_ADDRESS = "0xYourDeployedBaseOmniVaultAIAddress";

export const provider = new ethers.JsonRpcProvider(RPC_URL);
export const wallet = new ethers.Wallet(PRIVATE_KEY, provider);