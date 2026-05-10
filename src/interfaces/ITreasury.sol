// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITreasury {
    event GameAuthorizationUpdated(address indexed game, bool allowed);
    event RiskParamsUpdated(uint256 maxBetWei, uint256 maxPayoutWei, uint16 houseEdgeBps);
    event TreasuryPauseUpdated(bool isPaused);
    event BetDeposited(address indexed game, address indexed player, bytes32 indexed roundId, uint256 amount);
    event PayoutProcessed(
        address indexed game,
        address indexed player,
        bytes32 indexed roundId,
        uint256 grossAmount,
        uint256 feeAmount,
        uint256 netAmount
    );
    event RefundProcessed(address indexed game, address indexed player, bytes32 indexed roundId, uint256 amount);
    event EmergencyWithdrawal(address indexed to, uint256 amount);

    function depositBet(address player, uint256 amount, bytes32 roundId) external payable;
    function payout(address player, uint256 grossAmount, bytes32 roundId) external returns (uint256 netAmount);
    function refund(address player, uint256 amount, bytes32 roundId) external;

    function setGameAuthorization(address game, bool allowed) external;
    function setRiskParams(uint256 maxBetWei, uint256 maxPayoutWei, uint16 houseEdgeBps) external;
    function pause() external;
    function unpause() external;
    function emergencyWithdraw(address payable to, uint256 amount) external;

    function paused() external view returns (bool);
    function maxBetWei() external view returns (uint256);
    function maxPayoutWei() external view returns (uint256);
    function houseEdgeBps() external view returns (uint16);
    function isGameAuthorized(address game) external view returns (bool);

    function getTreasuryStats()
        external
        view
        returns (uint256 totalDeposited, uint256 totalPaidOut, uint256 totalRefunded, uint256 totalHouseProfit, uint256 balance);
}
