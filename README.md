# Base OmniVault AI

**Production-grade UUPS Upgradeable Smart Account (ERC-4337) built for autonomous AI agents on Base**

[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue)](https://soliditylang.org/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-Upgradeable-brightgreen)](https://docs.openzeppelin.com/)
[![ERC-4337](https://img.shields.io/badge/ERC--4337-Account%20Abstraction-purple)](https://eips.ethereum.org/EIPS/eip-4337)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Base](https://img.shields.io/badge/Chain-Base-0052FF)](https://base.org)

> A modular, security-first smart account designed for **controlled autonomy** of AI agents, passkey/biometric signers, social recovery, and safe DeFi execution on the Base ecosystem.

---

## Vision

Base OmniVault AI bridges the gap between **AI autonomy** and **on-chain safety**.  
It enables AI agents to execute trades and manage assets while remaining strictly constrained by daily limits, risk scores, cooldowns, oracle validation, circuit breakers, and multi-layered access control.

Built specifically for the **Base** ecosystem with native Aerodrome integration, gas tank sponsorship, and future-ready passkey support.

---

## Key Features

| Feature                      | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| **ERC-4337 Account Abstraction** | Full `validateUserOp` support + EntryPoint deposit/withdraw               |
| **AI Agent Policies**       | Daily spending limits, risk score (0-10), automatic daily reset            |
| **Session Keys**            | Time-bound + spending-capped temporary keys                                |
| **Passkey / WebAuthn Registry** | Structured storage ready for P-256 verification                          |
| **Social Recovery**         | Guardian threshold + deadline-based recovery flow                          |
| **Circuit Breaker**         | Automatic pause after consecutive execution failures                       |
| **Oracle Guard**            | Chainlink-compatible price feed + staleness protection                     |
| **Aerodrome Helper**        | Native `swapExactETHForTokens` with slippage & deadline protection         |
| **Module System**           | Secure enable/disable of external modules via `MODULE_ROLE`                |
| **Gas Tank**                | Sponsored gas deposits for agents                                          |
| **Linear Vesting**          | Native ETH + ERC-20 vesting with claim mechanism                           |
| **Two-step Admin Transfer** | Safe ownership handover                                                    |
| **UUPS Upgradeable**        | OpenZeppelin UUPS with timelock-ready authorization                        |

---

## Architecture
BaseOmniVaultAI (UUPS Proxy)
├── AccessControlUpgradeable + Pausable + ReentrancyGuard
├── ERC-4337 Validation Layer (validateUserOp)
├── AI Agent Policy Engine (daily limits + risk)
├── Session Key + Passkey Registry
├── Social Recovery Module
├── Trading Guards
│   ├── Whitelist
│   ├── Cooldown
│   ├── Max Trade Limit
│   └── Oracle Validation
├── Aerodrome Swap Helper
├── Module Registry
└── Utilities (Gas Tank • Linear Vesting • Emergency)


---

## Security Highlights

- **Multi-layered authorization**: Admin / Timelock / AI Agent / Session Key / Passkey / Module
- **Strict spending controls** for AI agents and session keys
- **Circuit breaker** auto-pauses after consecutive failures
- **Oracle staleness + bad price protection**
- **Whitelist + cooldown + max trade limit** on every trade path
- **Two-step admin transfer** + optional timelock
- **ReentrancyGuard** + custom errors for gas efficiency
- OpenZeppelin upgradeable contracts (battle-tested)

> This codebase has **not yet been audited**. Do not use with significant capital before a professional audit.

---

## Tech Stack

- Solidity `0.8.24` (viaIR + optimizer runs: 1 for size optimization)
- OpenZeppelin Contracts Upgradeable
- Hardhat + TypeChain + OpenZeppelin Upgrades plugin
- ERC-4337 EntryPoint v0.7 compatible
- Chainlink-style price feeds
- Aerodrome Router integration (Base native)

---

## Getting Started

### Prerequisites
- Node.js 18+
- npm / yarn
- Hardhat

### Installation & Testing

```bash
npm install
npx hardhat clean
npx hardhat compile
npx hardhat test

# Base Sepolia (recommended first)
npx hardhat run scripts/deploy.ts --network baseSepolia

# Base Mainnet
npx hardhat run scripts/deploy.ts --network base

PRIVATE_KEY=
ADMIN_ADDRESS=
TIMELOCK_ADDRESS=
ORACLE_ADDRESS=
ENTRY_POINT_ADDRESS=
BASESCAN_API_KEY=

AI Agent Keeper (Example)The repository includes a ready-to-extend AI keeper bot (ai-agent/):Rule-based signal analyzer (easily replaceable with LLM/ML)
On-chain policy & cooldown checks
Safe execution path for Aerodrome swaps

cd ai-agent
# Configure .env then
npx ts-node keeperBot.ts

Project Structure
contracts/
├── BaseOmniVaultAI.sol
└── mocks/
    ├── AeroRouterMock.sol
    ├── EntryPointMock.sol
    └── BaseMockPriceFeed.sol
scripts/
└── deploy.ts
test/
└── BaseOmniVaultAI(V3).test.ts
ai-agent/
├── config.ts
├── aiAnalyzer.ts
└── keeperBot.ts

RoadmapCore UUPS Smart Account + ERC-4337
AI Agent Policy Engine
Social Recovery + Session Keys
Aerodrome native helper
Circuit breaker + Oracle guards
Full WebAuthn / P-256 passkey verification
Formal audit
Multi-agent coordination module
On-chain risk scoring oracle integration
Frontend + Agent dashboard

Grant Fit & ImpactBase OmniVault AI directly advances several high-priority themes:AI × Crypto — Safe, constrained autonomy for AI agents on-chain
Account Abstraction — Production-ready ERC-4337 smart account
Base Ecosystem — Native Aerodrome integration + gas-efficient design
Security & Usability — Social recovery, passkeys, circuit breakers
Open Source Infrastructure — Fully open, modular, and upgradeable

It reduces the risk of runaway AI agents while enabling real DeFi utility on Base.

LicenseMIT

DisclaimerThis software is provided “as is”, without warranty of any kind.
Use at your own risk. Always conduct your own security review and testing before mainnet deployment with real funds.

