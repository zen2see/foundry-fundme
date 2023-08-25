// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from 'forge-std/Script.sol';
import {DevOpsTools} from 'foundry-devops/src/DevOpsTools.sol';
import {FundMe} from '../src/FundMe.sol';

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.2 ether;
    
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); 
        console.log('Interactions fundFundMe mostRecentDeployed address:', mostRecentlyDeployed);
        vm.stopBroadcast();
        console.log('Funded FundMe (mostRecentlyDeployed) with %s', SEND_VALUE);
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);  
        console.log('Interactions run() mostRecentDeployed address:', mostRecentlyDeployed);
        fundFundMe(mostRecentlyDeployed);
    }
} 

 contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);  
        withdrawFundMe(mostRecentlyDeployed);
    }
 }