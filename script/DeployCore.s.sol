// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {GameTreasury} from "../src/core/GameTreasury.sol";
import {VRFManager} from "../src/core/VRFManager.sol";

contract DeployCore is Script {
    function run() external returns (GameTreasury treasury, VRFManager vrfManager, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.account);
        treasury = new GameTreasury(config.maxBetWei, config.maxPayoutWei, config.houseEdgeBps);
        vrfManager = new VRFManager(
            config.subscriptionId, config.gasLane, config.callbackGasLimit, config.vrfCoordinatorV2_5
        );
        vm.stopBroadcast();
    }
}
