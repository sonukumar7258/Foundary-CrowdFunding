// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.t.sol";

contract helperNetworkConfig is Script {
    uint8 private constant ETH_DECIMALS = 8;
    int256 private constant ETH_INITIAL_NUMBER = 2000e8;

    NetworkConfig public network;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) network = getSepoliaEthToUsd();
        else if (block.chainid == 1) network = getMainnetEthToUsd();
        else network = getOrCreateAnvilEthToUsd();
    }

    function getSepoliaEthToUsd() private pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getMainnetEthToUsd() private pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
    }

    function getOrCreateAnvilEthToUsd() private returns (NetworkConfig memory) {
        if (network.priceFeed != address(0)) return network;

        vm.startBroadcast();
        MockV3Aggregator priceFeed = new MockV3Aggregator(
            ETH_DECIMALS,
            ETH_INITIAL_NUMBER
        );
        vm.stopBroadcast();

        return NetworkConfig({priceFeed: address(priceFeed)});
    }
}
