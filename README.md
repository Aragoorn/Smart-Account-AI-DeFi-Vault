<img width="1075" height="980" alt="Screenshot (2360)" src="https://github.com/user-attachments/assets/f7078824-da99-4345-b69e-3d61a0b9a4ef" />

# 🚀 Base OmniVault AI (Ultimate God-Tier Sovereign Smart Account)

> An enterprise-grade, autonomous Account Abstraction (ERC-4337) smart vault optimized for the **Base** ecosystem, featuring AI Agent automated strategies, Passkey biometrics, Social Recovery, and advanced multi-layered security.

---

## 🌟 Executive Summary & Architecture

**Base OmniVault AI** bridges the gap between next-generation Consumer Accounts and Autonomous AI Finance. The system is designed to provide maximum user security, biometric-first onboarding, and 24/7 automated portfolio management on the **Base** network.

> **Key Architectural Highlight:**  
> *"This contract is equipped with the Account Abstraction layer and is managed 24/7 and fully autonomously by an independent AI Agent operating via decentralized automation protocols on the Base network."*

---

## 📍 Network Deployments (Base Ecosystem)

| Network | Contract Name | Proxy Address / Status |
| :--- | :--- | :--- |
| **Base Sepolia (Testnet)** | `BaseOmniVaultAI` | `0xYourDeployedTestnetAddressHere` |
| **Base Mainnet** | `BaseOmniVaultAI` | `Coming Soon / Mainnet Ready` |

---

## 🛠️ Comprehensive Feature Breakdown

### 1. Account Abstraction & Next-Gen Signers (ERC-4337)
* **EntryPoint Integration:** Native compatibility with ERC-4337 infrastructure for batched operations and sponsored user experiences.
* **Passkey / WebAuthn Biometric Signers:** Users can manage and sign transactions using device-native biometrics (FaceID / TouchID) securely mapped via public keys (`pubKeyX`, `pubKeyY`).
* **Multi-Signer Vibenet Control:** Dynamic authorization registry allowing multiple execution signers alongside the primary admin.

### 2. Autonomous AI Agent Management
* **AI Agent Policies (`AgentPolicy`):** Restricts automated AI execution within strict daily spending limits (`dailyLimit`) and predefined risk scores (`riskScore`).
* **Automated Reset & Cooldowns:** Enforces strict transaction intervals (`tradeCooldown`) and automatically resets daily limits every 24 hours.

### 3. Institutional-Grade Security & Circuit Breakers
* **Automated Circuit Breaker:** If an AI agent or operator encounters 2 consecutive transaction failures (`MAX_CONSECUTIVE_FAILURES = 2`), the vault automatically triggers an emergency `pause()` to protect user assets.
* **Flash-Loan Vector Guard (`noFlashLoan`):** Blocks malicious atomic flash-loan attack vectors by validating transaction gas dynamics.
* **Chainlink Oracle Validation:** Validates real-time price feeds (`_checkOraclePrice`) and checks for price staleness (`PRICE_STALENESS_THRESHOLD`) before executing trades.
* **Slippage & Output Guard:** Integrates strict basis-point (BPS) slippage boundaries to protect trades against MEV and sandwich bots on Base DEXs (e.g., Aerodrome).

### 4. Decentralized Social Recovery Module
* **Guardian Network:** Designated social guardians (`isSocialGuardian`) can propose and approve signer recovery without relying on vulnerable private key backups.
* **Threshold-Based Execution:** Requires a minimum threshold (`recoveryThreshold`) of guardian approvals to safely rotate compromised keys.

### 5. Native Base Ecosystem & DeFi Routings
* **Aerodrome & DEX Integration:** Direct hooks (`executeNativeBaseStrategy`) to interact natively with top liquidity hubs and yield routers on Base.
* **Gas Tank / Sponsored Transactions:** Built-in account balance mapping (`gasTanks`) allowing apps or sponsors to subsidize user transaction fees seamlessly.

### 6. Built-in Linear Vesting & Governance Controls
* **Linear Vesting Schedules:** Trustless, time-locked beneficiary streaming (`setLinearVesting` & `claimVesting`) for token distribution.
* **Two-Step Admin Transfer:** Eliminates human error in ownership handovers through a secure proposal-and-acceptance workflow (`transferAdmin` / `acceptAdmin`).
* **Emergency Token Recovery:** Safe recovery handlers (`recoverStuckTokens` / `emergencyWithdraw`) for rescuing stranded assets.

---

## 📂 Project Repository Structure

```text
my-base-ai-vault/
├── contracts/
│   └── BaseOmniVaultAI.sol          # Ultimate UUPS Upgradeable Smart Account Contract
├── ai-agent/
│   ├── config.ts                    # Base network & provider configurations
│   ├── aiAnalyzer.ts                # AI market sentiment & strategy decision engine
│   └── keeperBot.ts                 # 24/7 Autonomous keeper execution loop
├── scripts/
│   └── deploy.ts                    # Hardhat deployment & initialization scripts
├── test/
│   └── BaseOmniVaultAI.test.ts      # Comprehensive line-by-line test suite
└── README.md                        # Project Documentation
```

---

## 🤖 How the Autonomous AI Keeper Works

The smart contract is controlled off-chain by an autonomous AI agent script:

1. **Market Monitoring:** The `aiAnalyzer.ts` module fetches liquidity metrics and price data from Base protocols.
2. **AI Decision Making:** Evaluates market parameters against pre-configured risk profiles.
3. **Automated Execution:** When criteria match, `keeperBot.ts` uses its authorized `AI_AGENT_ROLE` signature to securely call `executeTrade` or `executeBatchTrades` directly on the Base network.

---

## 🧪 Testing Suite & Coverage

To run the exhaustive test suite and verify all smart contract features:

```bash
# Install root dependencies
npm install

# Run Hardhat tests
npx hardhat test
```

---

## 🚀 Getting Started & Deployment

### Prerequisites

* Node.js & npm installed
* Hardhat environment setup

### 1. Install AI Agent Dependencies

```bash
cd ai-agent
npm install ethers dotenv
```

### 2. Configure Environment Variables

Create a `.env` file in your workspace:

```env
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
BASE_RPC_URL=https://mainnet.base.org
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
AI_AGENT_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ADMIN_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
TIMELOCK_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
ORACLE_ADDRESS=0x71041dddad3595f9ce4bcd3c09107954b377abca
ENTRY_POINT_ADDRESS=0x5FF137D4b0FDCD42Dca39c72516Le33A032Bd145
```

### 3. Deploy Contract via Hardhat

```bash
npx hardhat run scripts/deploy.ts --network base-sepolia
```

### 4. Run the AI Keeper Agent

```bash
npx ts-node ai-agent/keeperBot.ts
```

---

## 📜 License

This project is licensed under the **MIT License**
