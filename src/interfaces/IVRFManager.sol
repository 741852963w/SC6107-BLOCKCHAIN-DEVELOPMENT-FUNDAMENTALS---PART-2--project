// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVRFManager {
    struct RequestMetaView {
        address game;
        address player;
        bytes32 roundId;
        uint256 requestedAt;
        bool settled;
    }

    event GameAuthorizationUpdated(address indexed game, bool allowed);
    event RandomnessRequested(uint256 indexed requestId, address indexed game, bytes32 indexed roundId, address player);
    event RandomnessDelivered(uint256 indexed requestId, address indexed game, bytes32 indexed roundId, uint256 randomWord);

    function requestRandomness(bytes32 roundId, address player) external returns (uint256 requestId);
    function setGameAuthorization(address game, bool allowed) external;

    function isGameAuthorized(address game) external view returns (bool);
    function isRequestTimedOut(uint256 requestId, uint256 timeoutSeconds) external view returns (bool);
    function getRequestMeta(uint256 requestId) external view returns (RequestMetaView memory);
}
