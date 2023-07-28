// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

contract FundME is Script {
    uint256 constant AMOUNT = 0.01 ether;

    function initiateFunds(address mostRecentDeployedAddress) public {
        vm.startBroadcast();
        CrowdFunding(payable(mostRecentDeployedAddress)).fund{value: AMOUNT}();
        console.log("Amount = %s", AMOUNT);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedAddress = DevOpsTools
            .get_most_recent_deployment("CrowdFunding", block.chainid);
        // vm.startBroadcast();
        initiateFunds(mostRecentDeployedAddress);
        // vm.stopBroadcast();
    }
}

contract WithdrawFund is Script {
    function withdrawFunds(address mostRecentDeployedAddress) public {
        vm.startBroadcast();
        CrowdFunding(payable(mostRecentDeployedAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedAddress = DevOpsTools
            .get_most_recent_deployment("CrowdFunding", block.chainid);
        // vm.startBroadcast();
        withdrawFunds(mostRecentDeployedAddress);
        // vm.stopBroadcast();
    }
}
