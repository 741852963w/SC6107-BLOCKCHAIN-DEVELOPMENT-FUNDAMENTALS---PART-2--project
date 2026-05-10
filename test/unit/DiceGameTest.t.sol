// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {GameTreasury} from "../../src/core/GameTreasury.sol";
import {DiceGame} from "../../src/games/DiceGame.sol";
import {MockVRFManager} from "../mocks/MockVRFManager.sol";

contract DiceGameTest is Test {
    GameTreasury treasury;
    MockVRFManager vrfManager;
    DiceGame diceGame;
    address player = makeAddr("player");

    function setUp() external {
        treasury = new GameTreasury(1 ether, 5 ether, 300);
        vrfManager = new MockVRFManager();
        diceGame = new DiceGame(address(treasury), address(vrfManager), 10);

        treasury.setGameAuthorization(address(diceGame), true);
        vrfManager.setGameAuthorization(address(diceGame), true);

        vm.deal(player, 5 ether);
        vm.deal(address(this), 10 ether);
        (bool success,) = address(treasury).call{value: 5 ether}("");
        require(success, "seed treasury failed");
    }

    function testPlaceBetAndSettleWin() external {
        vm.prank(player);
        (uint256 betId, uint256 requestId) = diceGame.placeBet{value: 1 ether}(DiceGame.BetType.OVER, 3);

        assertEq(betId, 0);
        assertEq(requestId, 1);
        assertEq(address(treasury).balance, 6 ether);

        vrfManager.fulfill(requestId, 4); // roll = 5
        (, , , , , , bool settled, bool won, uint8 result, uint256 payout) = diceGame.s_bets(betId);

        assertTrue(settled);
        assertTrue(won);
        assertEq(result, 5);
        assertGt(payout, 0);
    }

    function testClaimTimeoutRefund() external {
        vm.prank(player);
        (uint256 betId,) = diceGame.placeBet{value: 1 ether}(DiceGame.BetType.EXACT, 2);

        vm.warp(block.timestamp + 11);
        vm.prank(player);
        diceGame.claimTimeoutRefund(betId);
        assertEq(player.balance, 5 ether);
    }
}
