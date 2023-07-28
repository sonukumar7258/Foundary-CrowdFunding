// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployCrowdFunding} from "../../script/DeployCrowdFunding.s.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";
import {FundME, WithdrawFund} from "../../script/Interactions.s.sol";

contract TestCrowdFunding is Test {
    CrowdFunding fund;

    address USER = makeAddr("user");
    uint256 constant AMOUNT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployCrowdFunding deployCrowdFunding = new DeployCrowdFunding();
        fund = deployCrowdFunding.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testFundInteractions() public {
        // Fund
        new FundME().initiateFunds(address(fund));

        // Withdraw
        new WithdrawFund().withdrawFunds(address(fund));

        assert(address(fund).balance == 0);
    }
}
