// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
// Import the contact to test 
import {FundMe} from '../src/FundMe.sol';
// Import Deploy Script
import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
    FundMe fundMe;

    // Make a fake user
    address USER = makeAddr('user');
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 17 zeros or 1e17
    uint256 constant STARTING_BALANCE  = 10 ether;
    uint256 constant GAS_PRICE = 1;

     // msg.sender -> FundMeTest -> FundMe  
    function setUp() external { 
        // fundMe = new FundMe();   
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); 
    }
      
    // Test one of the public functions of FundMe
    function testMinimumDollarsIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // Test if owner is msg.sender - Should FAIL because FundMeTest is the caller(owner)
    // WORKING NOW THAT WE ARE USING THE DEPLY SCRIPT EVEN FOR TEST
    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // Test is owner is address(this) - Should PASS because FundMeTest is the caller(owner)
    // function testOwnerIsAddressThis() public {
    //     console.log(fundMe.i_owner());
    //     console.log(address(this));
    //     assertEq(fundMe.i_owner(), address(this));
    // }

    // Test priceFeedVersion
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund(); // Sends 0 value so will revert
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by this USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER); 
        fundMe.fund{value: SEND_VALUE}();
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arange test
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act on test
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
      // Arrange test
      // uint160 for addresses uint256 i = uint256(uint160(msg.sender));
      uint160 numberOfFunders = 10; // uint160 for addresses
      uint160 startingFunderIndex = 1;
      for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
        hoax(address(1), SEND_VALUE); // hoax - Signature cheat code setup a prank from an address w/ether
        fundMe.fund{value: SEND_VALUE}; 
        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner()); // start-endPrank code in between will use the address provided
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        vm.stopPrank();
      }
      uint256 startingOwnerBalance = fundMe.getOwner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;
     
      // Assert
      assert(address(fundMe).balance == 0); 
      assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
  }

  function testCheaperWithdrawFromMultipleFunders() public funded {
      // Arrange test
      // uint160 for addresses uint256 i = uint256(uint160(msg.sender));
      uint160 numberOfFunders = 10; // uint160 for addresses
      uint160 startingFunderIndex = 1;
      for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
        hoax(address(1), SEND_VALUE); // hoax - Signature cheat code setup a prank from an address w/ether
        fundMe.fund{value: SEND_VALUE};
        // Act
        vm.startPrank(fundMe.getOwner()); // start-endPrank code in between will use t e address provided
        fundMe.cheaperWithdraw();
        vm.stopPrank();
      }
      uint256 startingOwnerBalance = fundMe.getOwner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;
     
      // Assert
      assert(address(fundMe).balance == 0); 
      assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
  }
}

   
