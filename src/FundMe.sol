// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {PriceConsumer} from "./PriceConsumer.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


error FundMe__NotOwner();

// private variables are more gas efficient

contract FundMe {
    using PriceConsumer for uint256;
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address[] private users;
    mapping (address user => uint256 amount) private usersBalanceSheeet;
    address private immutable i_owner;

    AggregatorV3Interface priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable  {
        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "Minimum amount of $5 is required");
        usersBalanceSheeet[msg.sender] += msg.value;
        users.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 index=0; index < users.length; index++) 
        {
            usersBalanceSheeet[users[index]] = 0;
        }
        users = new address[](0); // return array to zero

        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");

        require(success, "Failed to withdraw funds");
    }

    function getVersion() public view returns (uint256) {
      return priceFeed.version();
    }

    function getUserBalance(address _userAddress) public view returns (uint256) {
      return usersBalanceSheeet[_userAddress];
    }

    function getUserAddress(uint256 _index) public view returns (address) {
      return users[_index];
    }

    function getOwner() public view returns (address) {
      return i_owner;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner(); // saves gas from using require
        }
        _;
    }
}
