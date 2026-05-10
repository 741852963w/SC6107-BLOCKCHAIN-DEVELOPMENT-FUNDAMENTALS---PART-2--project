// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";
import {IVRFManager} from "../interfaces/IVRFManager.sol";
import {IGameCallback} from "../interfaces/IGameCallback.sol";

contract RaffleGame is AutomationCompatibleInterface, IGameCallback {
    error RaffleGame__InsufficientEntryFee();
    error RaffleGame__NotOpen();
    error RaffleGame__UpkeepNotNeeded();
    error RaffleGame__OnlyVrfManager();
    error RaffleGame__InvalidRequest();

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    ITreasury public immutable i_treasury;
    IVRFManager public immutable i_vrfManager;
    uint256 public immutable i_entranceFee;
    uint256 public immutable i_interval;

    RaffleState public s_raffleState;
    uint256 public s_lastTimeStamp;
    uint256 public s_roundId;
    address public s_recentWinner;

    address[] private s_players;
    mapping(uint256 roundId => uint256 amount) public s_roundPot;
    mapping(uint256 roundId => uint256 requestId) public s_roundRequestId;

    event RaffleEnter(address indexed player, uint256 indexed roundId, uint256 amount);
    event RaffleWinnerRequested(uint256 indexed requestId, uint256 indexed roundId);
    event RaffleWinnerPicked(address indexed winner, uint256 indexed roundId, uint256 payout);

    modifier onlyVrfManager() {
        if (msg.sender != address(i_vrfManager)) revert RaffleGame__OnlyVrfManager();
        _;
    }

    constructor(address treasury, address vrfManager, uint256 entranceFee, uint256 interval) {
        i_treasury = ITreasury(treasury);
        i_vrfManager = IVRFManager(vrfManager);
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (s_raffleState != RaffleState.OPEN) revert RaffleGame__NotOpen();
        if (msg.value < i_entranceFee) revert RaffleGame__InsufficientEntryFee();

        bytes32 roundKey = _roundKey(s_roundId);
        i_treasury.depositBet{value: msg.value}(msg.sender, msg.value, roundKey);

        s_players.push(msg.sender);
        s_roundPot[s_roundId] += msg.value;
        emit RaffleEnter(msg.sender, s_roundId, msg.value);
    }

    function checkUpkeep(bytes memory) public view override returns (bool upkeepNeeded, bytes memory) {
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool timePassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool hasPlayers = s_players.length > 0;
        bool hasPot = s_roundPot[s_roundId] > 0;
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasPot);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata) external override {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) revert RaffleGame__UpkeepNotNeeded();

        s_raffleState = RaffleState.CALCULATING;
        bytes32 roundKey = _roundKey(s_roundId);
        uint256 requestId = i_vrfManager.requestRandomness(roundKey, address(0));
        s_roundRequestId[s_roundId] = requestId;
        emit RaffleWinnerRequested(requestId, s_roundId);
        emit GameRoundRequested(requestId, roundKey, address(0));
    }

    function onRandomness(uint256 requestId, uint256 randomWord) external override onlyVrfManager {
        uint256 roundId = s_roundId;
        if (s_raffleState != RaffleState.CALCULATING || s_roundRequestId[roundId] != requestId) {
            revert RaffleGame__InvalidRequest();
        }

        uint256 winnerIndex = randomWord % s_players.length;
        address winner = s_players[winnerIndex];
        uint256 payout = s_roundPot[roundId];

        i_treasury.payout(winner, payout, _roundKey(roundId));

        s_recentWinner = winner;
        s_lastTimeStamp = block.timestamp;
        s_roundPot[roundId] = 0;
        delete s_players;
        s_raffleState = RaffleState.OPEN;

        emit RaffleWinnerPicked(winner, roundId, payout);
        emit GameRoundSettled(requestId, _roundKey(roundId), winner, true, payout, randomWord);
        s_roundId = roundId + 1;
    }

    function getPlayers() external view returns (address[] memory) {
        return s_players;
    }

    function getPlayerCount() external view returns (uint256) {
        return s_players.length;
    }

    function _roundKey(uint256 roundId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("RAFFLE", roundId));
    }
}
