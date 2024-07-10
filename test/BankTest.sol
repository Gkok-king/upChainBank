// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {Bank} from "../src/D7/Bank.sol";

contract BankTest is Test {
    event Deposit(address indexed user, uint amount);

    Bank bank;
    address user1 = address(0x1000000000000000000000000000000000000001);

    function setUp() public {
        bank = new Bank();
    }

    // 测试初始额
    function testInitialBalance() public view {
        uint balance = bank.balanceOf(user1);
        assertEq(balance, 0, "init is zero");
    }

    // 测试存
    function testDepositETH() public {
        uint amount = 10 ether;
        // 指定地址设置以太币余额。
        vm.deal(user1, amount);

        // 模拟人去存
        vm.prank(user1);
        bank.depositETH{value: amount}();

        uint balance = bank.balanceOf(user1);
        assertEq(balance, amount, "Balance did not update correctly");
    }

    // // 测试事件
    function testDepositETHEvent() public {
        uint amount = 11 ether;

        // 预期
        vm.expectEmit(true, true, false, true);
        emit Deposit(user1, amount);

        // 模拟
        vm.deal(user1, amount);
        vm.prank(user1);
        bank.depositETH{value: amount}();
    }

    // 测试存0
    function testDepositETHZero() public {
        uint amount = 0;
        vm.prank(user1);
        vm.expectRevert("Deposit amount must be greater than 0");
        bank.depositETH{value: amount}();
    }
}
