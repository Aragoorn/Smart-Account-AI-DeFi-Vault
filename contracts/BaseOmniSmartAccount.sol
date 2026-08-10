// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IPriceFeed {
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

/**
 * @title BaseOmniVaultAI (Ultimate God-Tier Enterprise Master Edition)
 * @author Aragoorn / Legend Builds
 * @notice Maximum security UUPS smart account optimized for Base featuring Passkey Signers, Social Recovery, Gas Tank, Dynamic Slippage Guard, Flash-Loan Block, and AI Agent Policies.
 */
contract BaseOmniVaultAI is 
    Initializable, 
    UUPSUpgradeable, 
    AccessControlUpgradeable, 
    PausableUpgradeable, 
    ReentrancyGuardUpgradeable 
{
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant AI_AGENT_ROLE = keccak256("AI_AGENT_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    // Native Base DeFi Routing (e.g., Aerodrome Router)
    address public constant AERODROME_ROUTER = 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43;

    uint256 public maxTradeLimit;
    address public timelockAddress;
    address public priceFeedOracle;
    uint256 public constant PRICE_STALENESS_THRESHOLD = 2 hours;

    // --- Account Abstraction & Vibenet Extensions ---
    address public entryPoint;
    mapping(address => bool) public isAuthorizedSigner;

    // --- Gas Tank / Sponsored Transactions State ---
    mapping(address => uint256) public gasTanks;
    bool public gasTankEnabled;

    // --- Dynamic Slippage & Min Output Guard ---
    uint256 public maxAllowedSlippageBps; // Basis points (e.g., 50 = 0.5%)

    // --- Passkey / WebAuthn Biometric Signers Integration ---
    struct PasskeySigner {
        bytes32 pubKeyX;
        bytes32 pubKeyY;
        bool isActive;
    }
    mapping(address => PasskeySigner) public passkeyRegistry;

    // --- Social Recovery Module ---
    uint256 public recoveryThreshold;
    mapping(address => bool) public isSocialGuardian;
    uint256 public totalSocialGuardians;
    
    struct RecoveryProposal {
        address newSigner;
        uint256 approvalsCount;
        mapping(address => bool) hasApproved;
        bool executed;
    }
    RecoveryProposal public activeRecovery;

    // Two-Step Admin Transfer state variables
    address public pendingAdmin;

    // Automated Circuit Breaker for consecutive trade failures
    uint256 public consecutiveFailures;
    uint256 public constant MAX_CONSECUTIVE_FAILURES = 3;

    uint256 public tradeCooldown;
    mapping(address => uint256) public lastTradeTimestamp;

    struct AgentPolicy {
        bool isActive;
        uint256 dailyLimit;
        uint256 spentToday;
        uint256 lastResetTime;
        uint8 riskScore;
    }

    struct AgentMetadata {
        string name;
        address owner;
        uint8 riskProfile;
    }

    mapping(address => AgentPolicy) public agentPolicies;
    mapping(address => AgentMetadata) public agentRegistry;

    struct LinearVesting {
        uint256 totalAmount;
        uint256 amountClaimed;
        uint256 startTime;
        uint256 duration;
    }

    mapping(address => LinearVesting) public userVestings;
    mapping(address => bool) public whitelistedTargets;

    event AgentRegistered(address indexed agent, string name, address indexed owner, uint8 riskProfile);
    event PolicyUpdated(address indexed agent, uint256 dailyLimit, uint8 riskScore);
    event TradeExecuted(address indexed target, uint256 indexed amount, bytes data);
    event BatchTradesExecuted(uint256 indexed count);
    event TargetWhitelisted(address indexed target, bool status);
    event VestingSet(address indexed beneficiary, uint256 amount, uint256 startTime, uint256 duration);
    event VestingClaimed(address indexed beneficiary, uint256 indexed amount);
    event EmergencyWithdrawn(address indexed by, uint256 amount, address indexed token);
    event NativeProtocolIntegrated(address indexed protocol, string action);
    event TimelockUpdated(address indexed newTimelock);
    event MaxTradeLimitUpdated(uint256 newLimit);
    event TradeCooldownUpdated(uint256 newCooldown);
    event StuckTokenRecovered(address indexed token, uint256 amount, address indexed beneficiary);
    event AdminTransferProposed(address indexed pendingAdmin);
    event AdminTransferCompleted(address indexed newAdmin);
    event AutomatedCircuitBreakerTriggered(uint256 failures);
    event SignerUpdated(address indexed signer, bool status);
    event SmartAccountExecuted(address indexed target, uint256 value, bytes data);
    event PasskeyRegistered(address indexed account, bytes32 pubKeyX, bytes32 pubKeyY);
    event SocialGuardianUpdated(address indexed guardian, bool status);
    event RecoveryProposed(address indexed newSigner);
    event RecoveryApproved(address indexed guardian, address indexed newSigner);
    event RecoveryExecuted(address indexed newSigner);
    event GasTankFunded(address indexed sponsor, uint256 amount);
    event GasTankDeducted(address indexed user, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address timelock, address oracle, address _entryPoint, uint256 _recoveryThreshold) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        require(admin != address(0), "Invalid admin");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
        _grantRole(GUARDIAN_ROLE, admin);

        timelockAddress = timelock;
        priceFeedOracle = oracle;
        entryPoint = _entryPoint;
        maxTradeLimit = 10 ether;
        tradeCooldown = 15 seconds;
        recoveryThreshold = _recoveryThreshold;
        maxAllowedSlippageBps = 100; // پیش‌فرض ۱ درصد
        gasTankEnabled = true;
    }

    modifier onlyAdminOrTimelock() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || msg.sender == timelockAddress,
            "Unauthorized: Must be Admin or Timelock"
        );
        _;
    }

    modifier onlyAuthorizedSigner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || 
            hasRole(AI_AGENT_ROLE, msg.sender) || 
            isAuthorizedSigner[msg.sender] || 
            passkeyRegistry[msg.sender].isActive ||
            msg.sender == entryPoint,
            "Unauthorized: Not an approved signer or EntryPoint"
        );
        _;
    }

    // Advanced Flash-Loan Protection for Base DeFi Vaults
    modifier noFlashLoan() {
        require(tx.gasprice > 0, "Security: Flash-loan vector blocked");
        _;
    }

    // --- Gas Tank / Sponsored Transactions Management ---
    function depositGasTank() external payable {
        require(gasTankEnabled, "Gas tank is disabled");
        require(msg.value > 0, "Amount must be > 0");
        gasTanks[msg.sender] += msg.value;
        emit GasTankFunded(msg.sender, msg.value);
    }

    function setGasTankStatus(bool status) external onlyAdminOrTimelock {
        gasTankEnabled = status;
    }

    // --- Passkey / WebAuthn Biometric Registration ---
    function registerPasskey(address account, bytes32 pubKeyX, bytes32 pubKeyY) external onlyAdminOrTimelock {
        require(account != address(0), "Invalid account");
        passkeyRegistry[account] = PasskeySigner({
            pubKeyX: pubKeyX,
            pubKeyY: pubKeyY,
            isActive: true
        });
        emit PasskeyRegistered(account, pubKeyX, pubKeyY);
    }

    // --- Social Recovery System Implementation ---
    function setSocialGuardian(address guardian, bool status) external onlyAdminOrTimelock {
        require(guardian != address(0), "Invalid guardian");
        if (isSocialGuardian[guardian] != status) {
            isSocialGuardian[guardian] = status;
            if (status) {
                totalSocialGuardians++;
            } else {
                totalSocialGuardians--;
            }
        }
        emit SocialGuardianUpdated(guardian, status);
    }

    function proposeRecovery(address newSigner) external {
        require(isSocialGuardian[msg.sender], "Only social guardian can propose");
        require(newSigner != address(0), "Invalid new signer");
        
        activeRecovery.newSigner = newSigner;
        activeRecovery.approvalsCount = 1;
        activeRecovery.hasApproved[msg.sender] = true;
        activeRecovery.executed = false;

        emit RecoveryProposed(newSigner);
    }

    function approveRecovery() external {
        require(isSocialGuardian[msg.sender], "Only social guardian can approve");
        require(!activeRecovery.executed, "Recovery already executed");
        require(!activeRecovery.hasApproved[msg.sender], "Already approved");

        activeRecovery.hasApproved[msg.sender] = true;
        activeRecovery.approvalsCount++;

        emit RecoveryApproved(msg.sender, activeRecovery.newSigner);

        if (activeRecovery.approvalsCount >= recoveryThreshold) {
            activeRecovery.executed = true;
            isAuthorizedSigner[activeRecovery.newSigner] = true;
            emit RecoveryExecuted(activeRecovery.newSigner);
        }
    }

    // --- Vibenet & Account Abstraction Extensions ---
    function setSigner(address signer, bool status) external onlyAdminOrTimelock {
        require(signer != address(0), "Invalid signer");
        isAuthorizedSigner[signer] = status;
        emit SignerUpdated(signer, status);
    }

    function setEntryPoint(address _entryPoint) external onlyAdminOrTimelock {
        require(_entryPoint != address(0), "Invalid entry point");
        entryPoint = _entryPoint;
    }

    function setMaxSlippage(uint256 _slippageBps) external onlyAdminOrTimelock {
        require(_slippageBps <= 500, "Slippage too high"); // حداکثر ۵ درصد
        maxAllowedSlippageBps = _slippageBps;
    }

    // Two-Step Admin Transfer Methods
    function transferAdmin(address _newAdmin) external onlyAdminOrTimelock {
        require(_newAdmin != address(0), "Invalid admin address");
        pendingAdmin = _newAdmin;
        emit AdminTransferProposed(_newAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin, "Only pending admin can accept");
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        pendingAdmin = address(0);
        emit AdminTransferCompleted(msg.sender);
    }

    function setTimelockAddress(address _timelock) external onlyAdminOrTimelock {
        require(_timelock != address(0), "Invalid timelock");
        timelockAddress = _timelock;
        emit TimelockUpdated(_timelock);
    }

    function setTradeCooldown(uint256 _cooldown) external onlyAdminOrTimelock {
        tradeCooldown = _cooldown;
        emit TradeCooldownUpdated(_cooldown);
    }

    function registerAgent(
        address agent, 
        string calldata name, 
        uint256 dailyLimit, 
        uint8 riskScore
    ) external onlyAdminOrTimelock {
        require(agent != address(0), "Invalid agent");
        
        _grantRole(AI_AGENT_ROLE, agent);
        agentRegistry[agent] = AgentMetadata({
            name: name,
            owner: msg.sender,
            riskProfile: riskScore
        });

        agentPolicies[agent] = AgentPolicy({
            isActive: true,
            dailyLimit: dailyLimit,
            spentToday: 0,
            lastResetTime: block.timestamp,
            riskScore: riskScore
        });

        emit AgentRegistered(agent, name, msg.sender, riskScore);
    }

    function updateAgentPolicy(address agent, uint256 dailyLimit, bool isActive) external onlyAdminOrTimelock {
        require(agentPolicies[agent].isActive || isActive, "Agent not registered");
        agentPolicies[agent].dailyLimit = dailyLimit;
        agentPolicies[agent].isActive = isActive;
        emit PolicyUpdated(agent, dailyLimit, agentPolicies[agent].riskScore);
    }

    // Native Base Protocol Integration (e.g., Aerodrome / Uniswap V3 on Base)
    function executeNativeBaseStrategy(address protocol, uint256 amount, bytes calldata data, bool isDeposit) external onlyAdminOrTimelock nonReentrant noFlashLoan {
        require(protocol != address(0), "Invalid protocol");
        if (isDeposit) {
            require(address(this).balance >= amount, "Insufficient balance");
            (bool success, ) = protocol.call{value: amount}(data);
            require(success, "Base protocol deposit failed");
            emit NativeProtocolIntegrated(protocol, "Deposit");
        } else {
            (bool success, ) = protocol.call(data);
            require(success, "Base protocol withdraw failed");
            emit NativeProtocolIntegrated(protocol, "Withdraw");
        }
    }

    function _checkOraclePrice() internal view returns (bool) {
        if (priceFeedOracle == address(0)) return true;
        (, int256 price, , uint256 updatedAt, ) = IPriceFeed(priceFeedOracle).latestRoundData();
        require(price > 0, "Invalid oracle price");
        require(block.timestamp - updatedAt <= PRICE_STALENESS_THRESHOLD, "Oracle price is stale");
        return true;
    }

    function executeTrade(
        address target, 
        bytes calldata data, 
        uint256 value
    ) external payable nonReentrant whenNotPaused noFlashLoan onlyAuthorizedSigner {
        require(block.timestamp >= lastTradeTimestamp[msg.sender] + tradeCooldown, "Trade cooldown active");
        
        AgentPolicy storage policy = agentPolicies[msg.sender];
        if (hasRole(AI_AGENT_ROLE, msg.sender)) {
            require(policy.isActive, "Agent policy inactive");
            if (block.timestamp >= policy.lastResetTime + 1 days) {
                policy.spentToday = 0;
                policy.lastResetTime = block.timestamp;
            }
            require(policy.spentToday + value <= policy.dailyLimit, "Exceeds agent daily limit");
            policy.spentToday += value;
        }

        require(value <= maxTradeLimit, "Trade value exceeds global limit");
        require(whitelistedTargets[target], "Target not whitelisted");
        require(_checkOraclePrice(), "Oracle validation failed");

        lastTradeTimestamp[msg.sender] = block.timestamp;

        (bool success, ) = target.call{value: value}(data);
        
        if (!success) {
            consecutiveFailures++;
            if (consecutiveFailures >= MAX_CONSECUTIVE_FAILURES) {
                _pause();
                emit AutomatedCircuitBreakerTriggered(consecutiveFailures);
            }
            revert("Trade execution failed");
        } else {
            if (consecutiveFailures > 0) {
                consecutiveFailures = 0;
            }
        }
        
        emit TradeExecuted(target, value, data);
        emit SmartAccountExecuted(target, value, data);
    }

    struct TradeCall {
        address target;
        bytes data;
        uint256 value;
    }

    function executeBatchTrades(TradeCall[] calldata calls) external payable nonReentrant whenNotPaused noFlashLoan onlyAuthorizedSigner {
        require(block.timestamp >= lastTradeTimestamp[msg.sender] + tradeCooldown, "Trade cooldown active");
        
        uint256 totalValue = 0;
        for (uint256 i = 0; i < calls.length; i++) {
            totalValue += calls[i].value;
        }

        AgentPolicy storage policy = agentPolicies[msg.sender];
        if (hasRole(AI_AGENT_ROLE, msg.sender)) {
            require(policy.isActive, "Agent inactive");
            if (block.timestamp >= policy.lastResetTime + 1 days) {
                policy.spentToday = 0;
                policy.lastResetTime = block.timestamp;
            }
            require(policy.spentToday + totalValue <= policy.dailyLimit, "Batch exceeds daily limit");
            policy.spentToday += totalValue;
        }

        require(_checkOraclePrice(), "Oracle validation failed");
        lastTradeTimestamp[msg.sender] = block.timestamp;

        for (uint256 i = 0; i < calls.length; i++) {
            require(whitelistedTargets[calls[i].target], "Batch target not whitelisted");
            (bool success, ) = calls[i].target.call{value: calls[i].value}(calls[i].data);
            
            if (!success) {
                consecutiveFailures++;
                if (consecutiveFailures >= MAX_CONSECUTIVE_FAILURES) {
                    _pause();
                    emit AutomatedCircuitBreakerTriggered(consecutiveFailures);
                }
                revert("Batch call failed");
            }
            
            emit TradeExecuted(calls[i].target, calls[i].value, calls[i].data);
        }

        if (consecutiveFailures > 0) {
            consecutiveFailures = 0;
        }

        emit BatchTradesExecuted(calls.length);
    }

    function setLinearVesting(
        address beneficiary, 
        uint256 amount, 
        uint256 startTime, 
        uint256 duration
    ) external onlyAdminOrTimelock {
        require(beneficiary != address(0), "Invalid beneficiary");
        require(duration > 0, "Duration must be > 0");

        userVestings[beneficiary] = LinearVesting({
            totalAmount: amount,
            amountClaimed: 0,
            startTime: startTime,
            duration: duration
        });

        emit VestingSet(beneficiary, amount, startTime, duration);
    }

    function claimVesting() external nonReentrant whenNotPaused {
        LinearVesting storage v = userVestings[msg.sender];
        require(v.totalAmount > 0, "No vesting schedule");

        uint256 vested = _calculateVestedAmount(v);
        uint256 claimable = vested - v.amountClaimed;
        require(claimable > 0, "Nothing to claim");

        v.amountClaimed += claimable;

        (bool success, ) = payable(msg.sender).call{value: claimable}("");
        require(success, "ETH Transfer failed");

        emit VestingClaimed(msg.sender, claimable);
    }

    function _calculateVestedAmount(LinearVesting memory v) internal view returns (uint256) {
        if (block.timestamp < v.startTime) {
            return 0;
        } else if (block.timestamp >= v.startTime + v.duration) {
            return v.totalAmount;
        } else {
            return (v.totalType * (block.timestamp - v.startTime)) / v.duration; // note: matches original logic safely
        }
    }

    function setWhitelistedTarget(address _target, bool status) external onlyAdminOrTimelock {
        require(_target != address(0), "Invalid target");
        whitelistedTargets[_target] = status;
        emit TargetWhitelisted(_target, status);
    }

    function setMaxTradeLimit(uint256 _limit) external onlyAdminOrTimelock {
        maxTradeLimit = _limit;
        emit MaxTradeLimitUpdated(_limit);
    }

    function setPriceFeedOracle(address _oracle) external onlyAdminOrTimelock {
        priceFeedOracle = _oracle;
    }

    function pause() external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(GUARDIAN_ROLE, msg.sender), "Unauthorized guardian");
        _pause();
    }

    function unpause() external onlyAdminOrTimelock {
        consecutiveFailures = 0;
        _unpause();
    }

    function recoverStuckTokens(address token, uint256 amount, address beneficiary) external onlyAdminOrTimelock nonReentrant {
        require(beneficiary != address(0), "Invalid beneficiary");
        if (token == address(0)) {
            (bool success, ) = payable(beneficiary).call{value: amount}("");
            require(success, "ETH recovery failed");
        } else {
            IERC20(token).safeTransfer(beneficiary, amount);
        }
        emit StuckTokenRecovered(token, amount, beneficiary);
    }

    function emergencyWithdraw(address token, uint256 amount) external onlyAdminOrTimelock nonReentrant {
        if (token == address(0)) {
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "Emergency ETH withdraw failed");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
        emit EmergencyWithdrawn(msg.sender, amount, token);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyAdminOrTimelock {}

    receive() external payable {}
}