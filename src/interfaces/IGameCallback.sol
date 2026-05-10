// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGameCallback {
    event GameRoundRequested(uint256 indexed requestId, bytes32 indexed roundId, address indexed player);
    event GameRoundSettled(
        uint256 indexed requestId, bytes32 indexed roundId, address indexed player, bool won, uint256 payout, uint256 randomWord
    );
    event GameRoundRefunded(uint256 indexed requestId, bytes32 indexed roundId, address indexed player, uint256 refundAmount);

    function onRandomness(uint256 requestId, uint256 randomWord) external;
}
