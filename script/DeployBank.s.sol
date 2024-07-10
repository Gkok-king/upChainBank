// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/MyBank.sol";

contract DeployBank is Script {
    function run() external {
        vm.startBroadcast();
        new MyBank();
        vm.stopBroadcast();
    }
}
