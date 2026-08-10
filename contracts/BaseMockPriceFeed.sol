// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title BaseMockPriceFeed
 * @notice Mock Price Feed oracle optimized for Base network testnet simulations and local Hardhat testing.
 *         Fully compatible with BaseOmniVaultAI price validation and circuit breaker checks.
 */
contract BaseMockPriceFeed {
    uint80 private s_roundId;
    int256 private s_price;
    uint256 private s_updatedAt;
    address public owner;

    event PriceUpdated(int256 newPrice, uint256 timestamp);

    constructor(int256 initialPrice) {
        owner = msg.sender;
        s_roundId = 1;
        s_price = initialPrice > 0 ? initialPrice : 3000 * 10**8; // Default mock price: $3000 with 8 decimals
        s_updatedAt = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /**
     * @notice Updates mock price for testing volatility, slippage or circuit breaker scenarios on Base
     */
    function setLatestPrice(int256 newPrice) external onlyOwner {
        require(newPrice > 0, "Invalid price");
        s_price = newPrice;
        s_roundId++;
        s_updatedAt = block.timestamp;
        emit PriceUpdated(newPrice, s_updatedAt);
    }

    /**
     * @notice Standard Chainlink-compatible interface matching BaseOmniVaultAI oracle checks
     */
    function latestRoundData() external view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    ) {
        return (
            s_roundId,          // roundId
            s_price,            // answer (Price with 8 decimals)
            s_updatedAt,        // startedAt
            s_updatedAt,        // updatedAt (Current timestamp to prevent staleness checks from failing)
            s_roundId           // answeredInRound
        );
    }
}