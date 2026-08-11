import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

export const CONFIG = {
  // Network
  RPC_URL: process.env.BASE_RPC || "https://mainnet.base.org",
  CHAIN_ID: 8453,

  // Contracts
  VAULT_ADDRESS: process.env.VAULT_ADDRESS || "",
  ENTRY_POINT: "0x0000000071727De22E5E9d8BAf0edAc6f37da032",

  // AI Agent
  AI_PRIVATE_KEY: process.env.AI_PRIVATE_KEY || "",
  MAX_RISK_SCORE: 8,
  DAILY_LIMIT_ETH: "5.0",
  TRADE_COOLDOWN_SEC: 35,

  // Oracle
  PRICE_FEED: process.env.ORACLE_ADDRESS || "0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70", // ETH/USD Base

  // Safety
  MAX_SLIPPAGE_BPS: 100,
  MIN_ETH_BALANCE: ethers.parseEther("0.05"),
};

export const VAULT_ABI = [
  "function executeTrade(address target, bytes data, uint256 value, uint256 minAmountOut) external payable",
  "function swapExactETHForTokensAerodrome(uint256 amountOutMin, address[] path, uint256 deadline) external payable",
  "function getAgentPolicy(address agent) view returns (tuple(bool isActive, uint256 dailyLimit, uint256 spentToday, uint48 lastResetTime, uint8 riskScore))",
  "function paused() view returns (bool)",
  "function maxTradeLimit() view returns (uint256)",
  "function tradeCooldown() view returns (uint256)",
  "function lastTradeTimestamp(address) view returns (uint256)",
  "event TradeExecuted(address indexed executor, address indexed target, uint256 value, bytes data)",
];