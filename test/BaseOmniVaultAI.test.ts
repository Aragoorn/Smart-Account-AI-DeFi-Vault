import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { BaseOmniVaultAI } from "../typechain-types";

describe("BaseOmniVaultAI - Line-by-Line Exhaustive Master Test Suite", function () {
  let vault: BaseOmniVaultAI;
  let owner: HardhatEthersSigner;
  let operator: HardhatEthersSigner;
  let aiAgent: HardhatEthersSigner;
  let guardian: HardhatEthersSigner;
  let user: HardhatEthersSigner;
  let timelock: HardhatEthersSigner;
  let recoveryGuardian1: HardhatEthersSigner;
  let recoveryGuardian2: HardhatEthersSigner;
  let unauthorizedUser: HardhatEthersSigner;

  const RECOVERY_THRESHOLD = 2;

  beforeEach(async function () {
    [
      owner,
      operator,
      aiAgent,
      guardian,
      user,
      timelock,
      recoveryGuardian1,
      recoveryGuardian2,
      unauthorizedUser,
    ] = await ethers.getSigners();

    const BaseOmniVaultAI = await ethers.getContractFactory("BaseOmniVaultAI");
    
    vault = (await upgrades.deployProxy(
      BaseOmniVaultAI,
      [owner.address, timelock.address, ethers.ZeroAddress, owner.address, RECOVERY_THRESHOLD],
      { initializer: "initialize", kind: "uups" }
    )) as unknown as BaseOmniVaultAI;
  });

  // ==========================================
  // 1. INITIALIZATION & UUPS UPGRADE TESTS
  // ==========================================
  describe("1. Initialization & UUPS Upgradeability", function () {
    it("Should set correct initial admin role", async function () {
      const DEFAULT_ADMIN_ROLE = await vault.DEFAULT_ADMIN_ROLE();
      expect(await vault.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.be.true;
    });

    it("Should set correct initial operator role", async function () {
      const OPERATOR_ROLE = await vault.OPERATOR_ROLE();
      expect(await vault.hasRole(OPERATOR_ROLE, owner.address)).to.be.true;
    });

    it("Should set correct initial guardian role", async function () {
      const GUARDIAN_ROLE = await vault.GUARDIAN_ROLE();
      expect(await vault.hasRole(GUARDIAN_ROLE, owner.address)).to.be.true;
    });

    it("Should set correct initial timelock address", async function () {
      expect(await vault.timelockAddress()).to.equal(timelock.address);
    });

    it("Should prevent re-initializing the contract", async function () {
      await expect(
        vault.initialize(owner.address, timelock.address, ethers.ZeroAddress, owner.address, RECOVERY_THRESHOLD)
      ).to.be.reverted;
    });
  });

  // ==========================================
  // 2. GRANULAR ACCESS CONTROL & ROLES
  // ==========================================
  describe("2. Granular Access Control & Roles", function () {
    it("Should allow admin to grant operator role", async function () {
      const OPERATOR_ROLE = await vault.OPERATOR_ROLE();
      await vault.grantRole(OPERATOR_ROLE, operator.address);
      expect(await vault.hasRole(OPERATOR_ROLE, operator.address)).to.be.true;
    });

    it("Should allow admin to revoke operator role", async function () {
      const OPERATOR_ROLE = await vault.OPERATOR_ROLE();
      await vault.grantRole(OPERATOR_ROLE, operator.address);
      await vault.revokeRole(OPERATOR_ROLE, operator.address);
      expect(await vault.hasRole(OPERATOR_ROLE, operator.address)).to.be.false;
    });

    it("Should handle two-step admin transfer proposal correctly", async function () {
      await vault.transferAdmin(operator.address);
      expect(await vault.pendingAdmin()).to.equal(operator.address);
    });

    it("Should reject admin acceptance from unauthorized account", async function () {
      await vault.transferAdmin(operator.address);
      await expect(
        vault.connect(unauthorizedUser).acceptAdmin()
      ).to.be.revertedWith("Not pending admin");
    });

    it("Should complete two-step admin transfer successfully", async function () {
      await vault.transferAdmin(operator.address);
      await vault.connect(operator).acceptAdmin();
      const DEFAULT_ADMIN_ROLE = await vault.DEFAULT_ADMIN_ROLE();
      expect(await vault.hasRole(DEFAULT_ADMIN_ROLE, operator.address)).to.be.true;
    });
  });

  // ==========================================
  // 3. SYSTEM CONFIGURATIONS & SETTERS
  // ==========================================
  describe("3. System Configurations & Setters", function () {
    it("Should update timelock address by admin", async function () {
      await vault.setTimelockAddress(user.address);
      expect(await vault.timelockAddress()).to.equal(user.address);
    });

    it("Should revert timelock update by non-admin", async function () {
      await expect(
        vault.connect(unauthorizedUser).setTimelockAddress(user.address)
      ).to.be.reverted;
    });

    it("Should update trade cooldown value", async function () {
      await vault.setTradeCooldown(60);
      expect(await vault.tradeCooldown()).to.equal(60);
    });

    it("Should toggle gas tank status correctly", async function () {
      await vault.setGasTankStatus(false);
      expect(await vault.gasTankEnabled()).to.be.false;

      await vault.setGasTankStatus(true);
      expect(await vault.gasTankEnabled()).to.be.true;
    });

    it("Should update whitelisted targets accurately", async function () {
      await vault.setWhitelistedTarget(user.address, true);
      expect(await vault.whitelistedTargets(user.address)).to.be.true;

      await vault.setWhitelistedTarget(user.address, false);
      expect(await vault.whitelistedTargets(user.address)).to.be.false;
    });
  });

  // ==========================================
  // 4. GAS TANK & SPONSORED TRANSACTIONS
  // ==========================================
  describe("4. Gas Tank & Sponsored Transactions", function () {
    it("Should accept deposits into gas tank", async function () {
      const depositVal = ethers.parseEther("1.5");
      await vault.connect(user).depositGasTank({ value: depositVal });
      expect(await vault.gasTanks(user.address)).to.equal(depositVal);
    });

    it("Should revert gas tank deposits when disabled", async function () {
      await vault.setGasTankStatus(false);
      await expect(
        vault.connect(user).depositGasTank({ value: ethers.parseEther("1.0") })
      ).to.be.revertedWith("Gas tank is disabled");
    });
  });

  // ==========================================
  // 5. BIOMETRIC PASSKEY REGISTRY
  // ==========================================
  describe("5. Biometric Passkey Registry", function () {
    it("Should register biometric passkey data correctly", async function () {
      const pkX = ethers.keccak256(ethers.toUtf8Bytes("pubKeyX"));
      const pkY = ethers.keccak256(ethers.toUtf8Bytes("pubKeyY"));

      await vault.registerPasskey(user.address, pkX, pkY);
      const passkey = await vault.passkeyRegistry(user.address);

      expect(passkey.isActive).to.be.true;
      expect(passkey.pubKeyX).to.equal(pkX);
      expect(passkey.pubKeyY).to.equal(pkY);
    });
  });

  // ==========================================
  // 6. SOCIAL RECOVERY MODULE
  // ==========================================
  describe("6. Social Recovery Module", function () {
    beforeEach(async function () {
      await vault.setSocialGuardian(recoveryGuardian1.address, true);
      await vault.setSocialGuardian(recoveryGuardian2.address, true);
    });

    it("Should configure social guardians properly", async function () {
      expect(await vault.socialGuardians(recoveryGuardian1.address)).to.be.true;
    });

    it("Should track recovery proposals and approvals to completion", async function () {
      const newSigner = user.address;

      await vault.connect(recoveryGuardian1).proposeRecovery(newSigner);
      expect(await vault.recoveryApprovalsCount()).to.equal(1);

      await vault.connect(recoveryGuardian2).approveRecovery();
      expect(await vault.isAuthorizedSigner(newSigner)).to.be.true;
    });
  });

  // ==========================================
  // 7. AI AGENT POLICIES & TRADING EXECUTION
  // ==========================================
  describe("7. AI Agent Policies & Trading Execution", function () {
    const dailyLimit = ethers.parseEther("5.0");

    beforeEach(async function () {
      await vault.registerAgent(aiAgent.address, "AlphaAgent", dailyLimit, 3);
      await vault.setWhitelistedTarget(user.address, true);
      await owner.sendTransaction({ to: await vault.getAddress(), value: ethers.parseEther("20.0") });
    });

    it("Should register AI agent policy successfully", async function () {
      const policy = await vault.agentPolicies(aiAgent.address);
      expect(policy.isActive).to.be.true;
      expect(policy.dailyLimit).to.equal(dailyLimit);
      expect(policy.riskScore).to.equal(3);
    });

    it("Should execute single trade within limits", async function () {
      const tradeAmount = ethers.parseEther("1.0");
      await ethers.provider.send("evm_increaseTime", [30]);
      await ethers.provider.send("evm_mine", []);

      await expect(
        vault.connect(aiAgent).executeTrade(user.address, "0x", tradeAmount)
      ).to.emit(vault, "TradeExecuted");
    });

    it("Should execute batch trades successfully", async function () {
      await ethers.provider.send("evm_increaseTime", [30]);
      await ethers.provider.send("evm_mine", []);

      const calls = [
        { target: user.address, data: "0x", value: ethers.parseEther("0.5") },
        { target: user.address, data: "0x", value: ethers.parseEther("0.5") }
      ];

      await expect(
        vault.connect(aiAgent).executeBatchTrades(calls)
      ).to.emit(vault, "BatchTradesExecuted");
    });

    it("Should revert trade if target is not whitelisted", async function () {
      await ethers.provider.send("evm_increaseTime", [30]);
      await ethers.provider.send("evm_mine", []);

      await expect(
        vault.connect(aiAgent).executeTrade(unauthorizedUser.address, "0x", ethers.parseEther("1.0"))
      ).to.be.revertedWith("Target not whitelisted");
    });

    it("Should revert trade if daily limit is exceeded", async function () {
      await ethers.provider.send("evm_increaseTime", [30]);
      await ethers.provider.send("evm_mine", []);

      await expect(
        vault.connect(aiAgent).executeTrade(user.address, "0x", ethers.parseEther("6.0"))
      ).to.be.revertedWith("Exceeds agent daily limit");
    });
  });

  // ==========================================
  // 8. NATIVE BASE STRATEGIES
  // ==========================================
  describe("8. Native Base Strategies", function () {
    it("Should execute native base protocol integration strategy", async function () {
      await owner.sendTransaction({ to: await vault.getAddress(), value: ethers.parseEther("5.0") });
      const amount = ethers.parseEther("1.0");

      await expect(
        vault.executeNativeBaseStrategy(user.address, amount, "0x", true)
      ).to.emit(vault, "NativeProtocolIntegrated");
    });
  });

  // ==========================================
  // 9. CIRCUIT BREAKER & EMERGENCY CONTROLS
  // ==========================================
  describe("9. Circuit Breaker & Emergency Controls", function () {
    beforeEach(async function () {
      await vault.registerAgent(aiAgent.address, "FailingAgent", ethers.parseEther("10.0"), 2);
      await vault.setWhitelistedTarget(owner.address, true);
    });

    it("Should trigger circuit breaker on consecutive failures and allow manual reset", async function () {
      for (let i = 0; i < 2; i++) {
        await ethers.provider.send("evm_increaseTime", [30]);
        await ethers.provider.send("evm_mine", []);

        await expect(
          vault.connect(aiAgent).executeTrade(owner.address, "0x888888", ethers.parseEther("0.1"))
        ).to.be.reverted;
      }

      expect(await vault.paused()).to.be.true;

      await vault.unpause();
      expect(await vault.paused()).to.be.false;
    });
  });

  // ==========================================
  // 10. LINEAR VESTING & EMERGENCY WITHDRAWALS
  // ==========================================
  describe("10. Linear Vesting & Emergency Withdrawals", function () {
    it("Should set and claim linear vesting successfully", async function () {
      const vestingVal = ethers.parseEther("2.0");
      const blockTime = (await ethers.provider.getBlock("latest"))!.timestamp;
      const start = blockTime + 10;
      const duration = 200;

      await vault.setLinearVesting(user.address, vestingVal, start, duration);
      await owner.sendTransaction({ to: await vault.getAddress(), value: vestingVal });

      await ethers.provider.send("evm_setNextBlockTimestamp", [start + 100]);
      await ethers.provider.send("evm_mine", []);

      const preBal = await ethers.provider.getBalance(user.address);
      await vault.connect(user).claimVesting();
      const postBal = await ethers.provider.getBalance(user.address);

      expect(postBal).to.be.gt(preBal);
    });

    it("Should perform emergency withdrawal of locked funds", async function () {
      const stuckAmount = ethers.parseEther("4.0");
      await owner.sendTransaction({ to: await vault.getAddress(), value: stuckAmount });

      const preBal = await ethers.provider.getBalance(owner.address);
      await vault.emergencyWithdraw(ethers.ZeroAddress, stuckAmount);
      const postBal = await ethers.provider.getBalance(owner.address);

      expect(postBal).to.be.gt(preBal);
    });
  });
});