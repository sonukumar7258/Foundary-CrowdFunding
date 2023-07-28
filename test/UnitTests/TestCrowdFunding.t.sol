// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployCrowdFunding} from "../../script/DeployCrowdFunding.s.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";

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

    function testMinimumUsd() public {
        assertEq(fund.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        assertEq(fund.getManagerAddress(), msg.sender);
    }

    function testVersion() public {
        assertEq(fund.getVersion(), 4);
    }

    function testFundFailWithMinimumAmount() public {
        vm.expectRevert(); // after the line should be revert line to pass this test case

        fund.fund();
    }

    function testFundsStorageVariables() public {
        vm.prank(USER);

        fund.fund{value: AMOUNT}();

        assertEq(fund.getAmountByFunderAddress(USER), AMOUNT);
    }

    function testFundersStorageVariables() public {
        vm.prank(USER);
        fund.fund{value: AMOUNT}();

        assertEq(fund.getFunderAddressByIndex(0), USER);
    }

    modifier Funded() {
        vm.prank(USER);
        fund.fund{value: AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public Funded {
        vm.prank(USER);
        vm.expectRevert();
        fund.withdraw();
    }

    function testWithdrawWithOneFunder() public Funded {
        uint256 managerStartingBalance = fund.getManagerAddress().balance;
        uint256 contractStartingBalance = address(fund).balance;

        vm.prank(fund.getManagerAddress());
        fund.withdraw();

        uint256 endingManagerBalance = fund.getManagerAddress().balance;
        uint256 endingContractBalance = address(fund).balance;

        assertEq(endingContractBalance, 0);
        assertEq(
            managerStartingBalance + contractStartingBalance,
            endingManagerBalance
        );
    }

    function testWithdrawWithMoreThanOneFunder() public Funded {
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            // hoax will do both like
            // 1 vm.prank()
            // 2 vm.deal()

            hoax(address(i), STARTING_BALANCE);
            fund.fund{value: STARTING_BALANCE}();
        }

        uint256 managerStartingBalance = fund.getManagerAddress().balance;
        uint256 contractStartingBalance = address(fund).balance;

        // startprank and stopprank will work previouly as prank but these define scop as compare to only use prank so use that professional practice
        vm.startPrank(fund.getManagerAddress());
        fund.withdraw();
        vm.stopPrank();

        assertEq(address(fund).balance, 0);
        assertEq(
            contractStartingBalance + managerStartingBalance,
            fund.getManagerAddress().balance
        );
    }
}
