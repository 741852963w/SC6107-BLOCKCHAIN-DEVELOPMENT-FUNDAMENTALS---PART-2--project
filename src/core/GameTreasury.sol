// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITreasury} from "../interfaces/ITreasury.sol";

contract GameTreasury is ITreasury {
    error GameTreasury__NotOwner();
    error GameTreasury__NotAuthorizedGame();
    error GameTreasury__Paused();
    error GameTreasury__InvalidValue();
    error GameTreasury__ExceedsMaxBet();
    error GameTreasury__ExceedsMaxPayout();
    error GameTreasury__InsufficientBalance();
    error GameTreasury__TransferFailed();
    error GameTreasury__InvalidRiskParams();

    uint16 private constant MAX_BPS = 10_000;

    address public immutable i_owner;
    bool public override paused;
    uint256 public override maxBetWei;
    uint256 public override maxPayoutWei;
    uint16 public override houseEdgeBps;

    uint256 private s_totalDeposited;
    uint256 private s_totalPaidOut;
    uint256 private s_totalRefunded;
    uint256 private s_totalHouseProfit;

    mapping(address game => bool allowed) private s_authorizedGames;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert GameTreasury__NotOwner();
        _;
    }

    modifier onlyGame() {
        if (!s_authorizedGames[msg.sender]) revert GameTreasury__NotAuthorizedGame();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert GameTreasury__Paused();
        _;
    }

    constructor(uint256 _maxBetWei, uint256 _maxPayoutWei, uint16 _houseEdgeBps) {
        if (_houseEdgeBps > MAX_BPS || _maxBetWei == 0 || _maxPayoutWei == 0 || _maxPayoutWei < _maxBetWei) {
            revert GameTreasury__InvalidRiskParams();
        }

        i_owner = msg.sender;
        maxBetWei = _maxBetWei;
        maxPayoutWei = _maxPayoutWei;
        houseEdgeBps = _houseEdgeBps;
    }

    function depositBet(address player, uint256 amount, bytes32 roundId) external payable override onlyGame whenNotPaused {
        if (player == address(0) || amount == 0) revert GameTreasury__InvalidValue();
        if (msg.value != amount) revert GameTreasury__InvalidValue();
        if (amount > maxBetWei) revert GameTreasury__ExceedsMaxBet();

        s_totalDeposited += amount;
        emit BetDeposited(msg.sender, player, roundId, amount);
    }

    function payout(address player, uint256 grossAmount, bytes32 roundId)
        external
        override
        onlyGame
        whenNotPaused
        returns (uint256 netAmount)
    {
        if (player == address(0) || grossAmount == 0) revert GameTreasury__InvalidValue();
        if (grossAmount > maxPayoutWei) revert GameTreasury__ExceedsMaxPayout();
        if (grossAmount > address(this).balance) revert GameTreasury__InsufficientBalance();

        uint256 feeAmount = (grossAmount * houseEdgeBps) / MAX_BPS;
        netAmount = grossAmount - feeAmount;

        s_totalHouseProfit += feeAmount;
        s_totalPaidOut += netAmount;

        (bool success,) = payable(player).call{value: netAmount}("");
        if (!success) revert GameTreasury__TransferFailed();

        emit PayoutProcessed(msg.sender, player, roundId, grossAmount, feeAmount, netAmount);
    }

    function refund(address player, uint256 amount, bytes32 roundId) external override onlyGame {
        if (player == address(0) || amount == 0) revert GameTreasury__InvalidValue();
        if (amount > address(this).balance) revert GameTreasury__InsufficientBalance();

        s_totalRefunded += amount;
        (bool success,) = payable(player).call{value: amount}("");
        if (!success) revert GameTreasury__TransferFailed();

        emit RefundProcessed(msg.sender, player, roundId, amount);
    }

    function setGameAuthorization(address game, bool allowed) external override onlyOwner {
        s_authorizedGames[game] = allowed;
        emit GameAuthorizationUpdated(game, allowed);
    }

    function setRiskParams(uint256 _maxBetWei, uint256 _maxPayoutWei, uint16 _houseEdgeBps) external override onlyOwner {
        if (_houseEdgeBps > MAX_BPS || _maxBetWei == 0 || _maxPayoutWei == 0 || _maxPayoutWei < _maxBetWei) {
            revert GameTreasury__InvalidRiskParams();
        }
        maxBetWei = _maxBetWei;
        maxPayoutWei = _maxPayoutWei;
        houseEdgeBps = _houseEdgeBps;
        emit RiskParamsUpdated(_maxBetWei, _maxPayoutWei, _houseEdgeBps);
    }

    function pause() external override onlyOwner {
        paused = true;
        emit TreasuryPauseUpdated(true);
    }

    function unpause() external override onlyOwner {
        paused = false;
        emit TreasuryPauseUpdated(false);
    }

    function emergencyWithdraw(address payable to, uint256 amount) external override onlyOwner {
        if (to == address(0) || amount == 0) revert GameTreasury__InvalidValue();
        if (amount > address(this).balance) revert GameTreasury__InsufficientBalance();

        (bool success,) = to.call{value: amount}("");
        if (!success) revert GameTreasury__TransferFailed();
        emit EmergencyWithdrawal(to, amount);
    }

    function isGameAuthorized(address game) external view override returns (bool) {
        return s_authorizedGames[game];
    }

    function getTreasuryStats()
        external
        view
        override
        returns (uint256 totalDeposited, uint256 totalPaidOut, uint256 totalRefunded, uint256 totalHouseProfit, uint256 balance)
    {
        return (s_totalDeposited, s_totalPaidOut, s_totalRefunded, s_totalHouseProfit, address(this).balance);
    }

    receive() external payable {}
}
