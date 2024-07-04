// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;
    address admin = address(0xd51b4c5483513CF83071fb2E0dF7dbf30c4AC503);
    address user1 = address(0x1000000000000000000000000000000000000001);
    address user2 = address(0x1000000000000000000000000000000000000002);
    address user3 = address(0x1000000000000000000000000000000000000003);
    address user4 = address(0x1000000000000000000000000000000000000004);

    function setUp() public {
        bank = new Bank();
    }

    function testDeposit() public {
        // User1 deposits 1 ether
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        (address user, uint256 amount) = bank.getDeposit(0);
        assertEq(user, user1);
        assertEq(amount, 1 ether);

        // User2 deposits 2 ether
        vm.deal(user2, 2 ether);
        vm.prank(user2);
        bank.deposit{value: 2 ether}();
        (user, amount) = bank.getDeposit(1);
        assertEq(user, user2);
        assertEq(amount, 2 ether);

        // User3 deposits 3 ether
        vm.deal(user3, 3 ether);
        vm.prank(user3);
        bank.deposit{value: 3 ether}();
        (user, amount) = bank.getDeposit(2);
        assertEq(user, user3);
        assertEq(amount, 3 ether);
    }

    function testWithdraw() public {
        // Deposit 1 ether from user1
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        // Admin withdraws the funds
        vm.startPrank(admin);
        bank.withdraw();
        vm.stopPrank();

        // Verify the balance of the contract is 0
        uint256 balance = address(bank).balance;
        assertEq(balance, 0);
    }

    function testNonAdminCannotWithdraw() public {
        // Deposit 1 ether from user1
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        // User2 tries to withdraw funds
        vm.prank(user2);
        vm.expectRevert("Only admin can call this function.");
        bank.withdraw();
    }

    function testDepositLimit() public {
        // User1 deposits
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        // User2 deposits
        vm.deal(user2, 2 ether);
        vm.prank(user2);
        bank.deposit{value: 2 ether}();

        // User3 deposits
        vm.deal(user3, 3 ether);
        vm.prank(user3);
        bank.deposit{value: 3 ether}();

        // User4 deposits
        vm.deal(user4, 4 ether);
        vm.prank(user4);
        bank.deposit{value: 4 ether}();

        // Verify that only three deposits are recorded
        vm.expectRevert("Index out of bounds.");
        bank.getDeposit(3);
    }
}