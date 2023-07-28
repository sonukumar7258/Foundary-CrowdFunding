// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";
import {helperNetworkConfig} from "../script/helperNetworkConfig.s.sol";

contract DeployCrowdFunding is Script {
    function run() external returns (CrowdFunding) {
        helperNetworkConfig networkConfig = new helperNetworkConfig();

        address priceFeed = networkConfig.network();

        vm.startBroadcast();
        CrowdFunding fund = new CrowdFunding(priceFeed);
        vm.stopBroadcast();

        return fund;
    }
}
