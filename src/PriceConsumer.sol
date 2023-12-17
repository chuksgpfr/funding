//SPDX-License-Identifier: UNLICENSED

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

pragma solidity ^0.8.18;

library PriceConsumer {

    function getConversionRate(uint256 _ethAmount, AggregatorV3Interface priceFeed) public view returns(uint256) {
        uint256 ethUSDPrice = getEthUSDRate(priceFeed);

        uint256 result = (ethUSDPrice * _ethAmount) / 1e18;

        return result;
    }

    function getEthUSDRate(AggregatorV3Interface priceFeed) private view returns(uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();

        // price has 8 decimal places so we add 10 more to make 18
        return uint256(price) * 1e10;
    }
}

