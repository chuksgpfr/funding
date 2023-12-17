//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Console.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe fundMe;
  address USER =  makeAddr("khagan"); // this generates an address
  uint256 SEND_AMOUNT = 0.1 ether;
  uint256 STARTING_BALANCE = 1 ether;

  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
  }

  function testMinDepositIsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwner() public {
    assertEq(fundMe.getOwner(), msg.sender);
  }

  function testPriceFeedVersion() public {
    assertEq(fundMe.getVersion(), 4);
  }

  function testFundFailed() public {
    vm.expectRevert();
    fundMe.fund(); // sends 0 value
  }

  function testFundPass() public {
    vm.prank(USER); // the next tx will be sent by USER
    vm.deal(USER, STARTING_BALANCE); // give them fake money for test
    fundMe.fund{value: SEND_AMOUNT}(); // sends 0 value
    uint256 amount = fundMe.getUserBalance(USER);
    assertEq(amount, SEND_AMOUNT);
  }

  function testAddFunderToBalanceSheet() public {
    vm.prank(USER);
    vm.deal(USER, STARTING_BALANCE);
    fundMe.fund{value: SEND_AMOUNT}();
    address funder = fundMe.getUserAddress(0);
    assertEq(USER, funder);
  }

  modifier fund() {
    vm.prank(USER);
    vm.deal(USER, STARTING_BALANCE);
    fundMe.fund{value: SEND_AMOUNT}();
    _;
  }

  function testOnlyOwnerCanWithdraw() public fund {
    vm.prank(USER);
    vm.expectRevert();
    fundMe.withdraw();
  }

  function testWithdrawal() public fund {
    uint256 fundMeStartingBalance = address(fundMe).balance;
    uint256 ownerStartingBalance = fundMe.getOwner().balance;

    vm.prank(fundMe.getOwner());
    fundMe.withdraw();


    uint256 fundMeEndBalance = address(fundMe).balance;
    uint256 ownerEndBalance = fundMe.getOwner().balance;

    assertEq(fundMeEndBalance, 0);
    assertEq(fundMeStartingBalance + ownerStartingBalance, ownerEndBalance);
  }

  function testWithdrawFromMultipleAccount() public {
    // Arrange
    uint160 startIndex = 1;
    uint160 endIndex = 10;

    for (uint160 i = startIndex; i < endIndex; i++) {
      hoax(address(i), SEND_AMOUNT);
      fundMe.fund{value: SEND_AMOUNT}();
    }

    uint256 fundMeStartingBalance = address(fundMe).balance;
    uint256 ownerStartingBalance = fundMe.getOwner().balance;

    // Act
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    // Assert
    assertEq(address(fundMe).balance, 0);
    assertEq(fundMeStartingBalance + ownerStartingBalance, fundMe.getOwner().balance);
  }
}