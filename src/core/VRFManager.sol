// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFManager} from "../interfaces/IVRFManager.sol";
import {IGameCallback} from "../interfaces/IGameCallback.sol";

contract VRFManager is VRFConsumerBaseV2Plus, IVRFManager {
    error VRFManager__NotOwner();
    error VRFManager__NotAuthorizedGame();
    error VRFManager__InvalidRequest();

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    address public immutable i_owner;
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;

    struct RequestMeta {
        address game;
        address player;
        bytes32 roundId;
        uint256 requestedAt;
        bool settled;
    }

    mapping(address game => bool allowed) private s_authorizedGames;
    mapping(uint256 requestId => RequestMeta requestMeta) private s_requestMeta;

    modifier onlyAdmin() {
        if (msg.sender != i_owner) revert VRFManager__NotOwner();
        _;
    }

    modifier onlyGame() {
        if (!s_authorizedGames[msg.sender]) revert VRFManager__NotAuthorizedGame();
        _;
    }

    constructor(uint256 subscriptionId, bytes32 gasLane, uint32 callbackGasLimit, address vrfCoordinatorV2_5)
        VRFConsumerBaseV2Plus(vrfCoordinatorV2_5)
    {
        i_owner = msg.sender;
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
    }

    function requestRandomness(bytes32 roundId, address player) external override onlyGame returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        s_requestMeta[requestId] =
            RequestMeta({game: msg.sender, player: player, roundId: roundId, requestedAt: block.timestamp, settled: false});

        emit RandomnessRequested(requestId, msg.sender, roundId, player);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        RequestMeta storage requestMeta = s_requestMeta[requestId];
        if (requestMeta.game == address(0) || requestMeta.settled) revert VRFManager__InvalidRequest();

        requestMeta.settled = true;
        emit RandomnessDelivered(requestId, requestMeta.game, requestMeta.roundId, randomWords[0]);
        IGameCallback(requestMeta.game).onRandomness(requestId, randomWords[0]);
    }

    function setGameAuthorization(address game, bool allowed) external override onlyAdmin {
        s_authorizedGames[game] = allowed;
        emit GameAuthorizationUpdated(game, allowed);
    }

    function isGameAuthorized(address game) external view override returns (bool) {
        return s_authorizedGames[game];
    }

    function isRequestTimedOut(uint256 requestId, uint256 timeoutSeconds) external view override returns (bool) {
        RequestMeta memory requestMeta = s_requestMeta[requestId];
        if (requestMeta.requestedAt == 0 || requestMeta.settled) {
            return false;
        }
        return block.timestamp > requestMeta.requestedAt + timeoutSeconds;
    }

    function getRequestMeta(uint256 requestId) external view override returns (RequestMetaView memory) {
        RequestMeta memory requestMeta = s_requestMeta[requestId];
        return RequestMetaView({
            game: requestMeta.game,
            player: requestMeta.player,
            roundId: requestMeta.roundId,
            requestedAt: requestMeta.requestedAt,
            settled: requestMeta.settled
        });
    }
}
