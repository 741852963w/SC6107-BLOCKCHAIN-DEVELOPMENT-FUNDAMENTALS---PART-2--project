// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {GameTreasury} from "../../src/core/GameTreasury.sol";
import {RaffleGame} from "../../src/games/RaffleGame.sol";
import {MockVRFManager} from "../mocks/MockVRFManager.sol";

contract RaffleGameTest is Test {
    GameTreasury treasury;
    MockVRFManager vrfManager;
    RaffleGame raffleGame;

    address player1 = makeAddr("p1");
    address player2 = makeAddr("p2");

    function setUp() external {
        treasury = new GameTreasury(1 ether, 5 ether, 300);
        vrfManager = new MockVRFManager();
        raffleGame = new RaffleGame(address(treasury), address(vrfManager), 0.1 ether, 5);
        treasury.setGameAuthorization(address(raffleGame), true);
        vrfManager.setGameAuthorization(address(raffleGame), true);

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
    }

    function testEnterAndPickWinner() external {
        vm.prank(player1);
        raffleGame.enterRaffle{value: 0.1 ether}();
        vm.prank(player2);
        raffleGame.enterRaffle{value: 0.1 ether}();

        vm.warp(block.timestamp + 6);
        raffleGame.performUpkeep("");
        uint256 requestId = raffleGame.s_roundRequestId(0);
        vrfManager.fulfill(requestId, 3);

        assertEq(raffleGame.s_roundId(), 1);
        assertEq(uint256(raffleGame.s_raffleState()), 0);
    }
}
