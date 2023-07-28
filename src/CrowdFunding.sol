// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error CrowdFunding_NotOwner();

contract CrowdFunding {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address private immutable i_manager;
    address[] private s_funders;
    mapping(address => uint256) private s_AddresstoUsdAmount;

    AggregatorV3Interface private s_price_feed;

    constructor(address priceFeed) {
        i_manager = msg.sender;
        s_price_feed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != i_manager) revert CrowdFunding_NotOwner();
        _;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_price_feed) >= MINIMUM_USD,
            "You have to fund atleast 5usd!"
        );
        // becasue anyone can fund
        s_funders.push(msg.sender);
        s_AddresstoUsdAmount[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_price_feed.version();
    }

    function withdraw() public onlyOwner {
        uint256 funders_length = s_funders.length;

        for (uint i = 0; i < funders_length; i++) {
            address funder = s_funders[i];
            s_AddresstoUsdAmount[funder] = 0;
        }
        s_funders = new address[](0);

        // payable(msg.sender).transfer(address(this).balance);

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call Failed!");
    }

    function getAmountByFunderAddress(
        address funderAddress
    ) external view returns (uint256) {
        return s_AddresstoUsdAmount[funderAddress];
    }

    function getFunderAddressByIndex(
        uint256 index
    ) external view returns (address) {
        return s_funders[index];
    }

    function getManagerAddress() external view returns (address) {
        return i_manager;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
