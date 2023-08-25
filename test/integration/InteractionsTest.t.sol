// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
// Import the contact to test 
import {FundMe} from '../../src/FundMe.sol';
// Import Deploy Script
import {DeployFundMe} from '../../script/DeployFundMe.s.sol';
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';
//import {HelperConfig} from '../../script/HelperConfig.sol';

contract InteractionsTest is Test {
    FundMe fundMe;
    // Make a fake user
    address USER = makeAddr('user');
    uint256 public constant SEND_VALUE = 0.2 ether; // 100000000000000000 17 zeros or 1e17
    uint256 public constant STARTING_BALANCE  = 5 ether;
    uint256 public constant GAS_PRICE = 1;

    // msg.sender -> FundMeTest -> FundMe  
    function setUp() external { 
        // fundMe = new FundMe();   
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE); 
        console.log('InteractionsTest User', USER);
        // console.log('InteractionsTest User Balance');
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        console.log('testUserCanFundInteractions() USER', USER);
        console.log('testUserCanFundInteractions() USER.balance', USER.balance);
        console.log('msg.sender address', msg.sender);
        console.log('msg.sender.balance', msg.sender.balance);
       
        console.log('testUserCanFundInteractions() address(fundMe)', address(fundMe));
        console.log('testUserCanFundInteractions() address(fundMe).balance', address(fundMe).balance);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        console.log('testUserCanFundInteractions() address funder/fundMe balance after withdraw', address(fundMe).balance);
        console.log('testUserCanFundInteractions() USER.balance after withdraw', USER.balance);
        console.log('msg.sender.balance', msg.sender.balance);
        assert(address(fundMe).balance == 0);
        console.log('0x72384992222BE015DE0146a6D7E5dA0E19d2Ba49.balance', 0x72384992222BE015DE0146a6D7E5dA0E19d2Ba49.balance);
        console.log('FundMe.i_owner', fundMe.getOwner());
        console.log('FundMe.i_owner balance', fundMe.getOwner().balance);
    }
} 