// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITreasury} from "../interfaces/ITreasury.sol";
import {IVRFManager} from "../interfaces/IVRFManager.sol";
import {IGameCallback} from "../interfaces/IGameCallback.sol";

contract DiceGame is IGameCallback {
    error DiceGame__OnlyVrfManager();
    error DiceGame__InvalidPrediction();
    error DiceGame__InvalidWager();
    error DiceGame__AlreadySettled();
    error DiceGame__NotBetOwner();
    error DiceGame__RefundNotAvailable();

    enum BetType {
        OVER,
        UNDER,
        EXACT
    }

    struct DiceBet {
        address player;
        uint256 amount;
        BetType betType;
        uint8 prediction;
        uint256 requestId;
        uint256 placedAt;
        bool settled;
        bool won;
        uint8 result;
        uint256 payout;
    }

    uint256 private constant BPS = 10_000;
    uint256 private constant OVER_UNDER_PAYOUT_BPS = 18_000; // 1.8x
    uint256 private constant EXACT_PAYOUT_BPS = 55_000; // 5.5x

    ITreasury public immutable i_treasury;
    IVRFManager public immutable i_vrfManager;
    uint256 public immutable i_timeoutSeconds;

    uint256 public s_nextBetId;
    mapping(uint256 betId => DiceBet bet) public s_bets;
    mapping(uint256 requestId => uint256 betId) public s_requestToBetId;

    event DiceBetPlaced(
        uint256 indexed betId, uint256 indexed requestId, address indexed player, uint256 amount, BetType betType, uint8 prediction
    );
    event DiceBetSettled(
        uint256 indexed betId, uint256 indexed requestId, address indexed player, uint8 result, bool won, uint256 payout
    );
    event DiceBetRefunded(uint256 indexed betId, uint256 indexed requestId, address indexed player, uint256 amount);

    modifier onlyVrfManager() {
        if (msg.sender != address(i_vrfManager)) revert DiceGame__OnlyVrfManager();
        _;
    }

    constructor(address treasury, address vrfManager, uint256 timeoutSeconds) {
        i_treasury = ITreasury(treasury);
        i_vrfManager = IVRFManager(vrfManager);
        i_timeoutSeconds = timeoutSeconds;
    }

    function placeBet(BetType betType, uint8 prediction) external payable returns (uint256 betId, uint256 requestId) {
        if (msg.value == 0) revert DiceGame__InvalidWager();
        _validatePrediction(betType, prediction);

        betId = s_nextBetId++;
        bytes32 roundId = _roundKey(betId);
        i_treasury.depositBet{value: msg.value}(msg.sender, msg.value, roundId);
        requestId = i_vrfManager.requestRandomness(roundId, msg.sender);

        s_bets[betId] = DiceBet({
            player: msg.sender,
            amount: msg.value,
            betType: betType,
            prediction: prediction,
            requestId: requestId,
            placedAt: block.timestamp,
            settled: false,
            won: false,
            result: 0,
            payout: 0
        });
        s_requestToBetId[requestId] = betId;

        emit DiceBetPlaced(betId, requestId, msg.sender, msg.value, betType, prediction);
        emit GameRoundRequested(requestId, roundId, msg.sender);
    }

    function onRandomness(uint256 requestId, uint256 randomWord) external override onlyVrfManager {
        uint256 betId = s_requestToBetId[requestId];
        DiceBet storage bet = s_bets[betId];
        if (bet.player == address(0)) revert DiceGame__RefundNotAvailable();
        if (bet.settled) revert DiceGame__AlreadySettled();

        uint8 roll = uint8((randomWord % 6) + 1);
        bool won = _isWinningBet(bet.betType, bet.prediction, roll);
        uint256 payoutAmount = 0;
        if (won) {
            uint256 multiplier = bet.betType == BetType.EXACT ? EXACT_PAYOUT_BPS : OVER_UNDER_PAYOUT_BPS;
            uint256 gross = (bet.amount * multiplier) / BPS;
            payoutAmount = i_treasury.payout(bet.player, gross, _roundKey(betId));
        }

        bet.result = roll;
        bet.won = won;
        bet.payout = payoutAmount;
        bet.settled = true;

        emit DiceBetSettled(betId, requestId, bet.player, roll, won, payoutAmount);
        emit GameRoundSettled(requestId, _roundKey(betId), bet.player, won, payoutAmount, randomWord);
    }

    function claimTimeoutRefund(uint256 betId) external {
        DiceBet storage bet = s_bets[betId];
        if (bet.player != msg.sender) revert DiceGame__NotBetOwner();
        if (bet.settled) revert DiceGame__AlreadySettled();
        if (!i_vrfManager.isRequestTimedOut(bet.requestId, i_timeoutSeconds)) revert DiceGame__RefundNotAvailable();

        bet.settled = true;
        i_treasury.refund(bet.player, bet.amount, _roundKey(betId));

        emit DiceBetRefunded(betId, bet.requestId, bet.player, bet.amount);
        emit GameRoundRefunded(bet.requestId, _roundKey(betId), bet.player, bet.amount);
    }

    function _validatePrediction(BetType betType, uint8 prediction) internal pure {
        if (betType == BetType.EXACT && (prediction < 1 || prediction > 6)) revert DiceGame__InvalidPrediction();
        if ((betType == BetType.OVER || betType == BetType.UNDER) && (prediction < 1 || prediction > 5)) {
            revert DiceGame__InvalidPrediction();
        }
    }

    function _isWinningBet(BetType betType, uint8 prediction, uint8 roll) internal pure returns (bool) {
        if (betType == BetType.OVER) return roll > prediction;
        if (betType == BetType.UNDER) return roll < prediction;
        return roll == prediction;
    }

    function _roundKey(uint256 betId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("DICE", betId));
    }
}
