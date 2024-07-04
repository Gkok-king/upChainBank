// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 编写一个 Bank 合约，实现功能：

// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

contract Bank {
    // admin 用户
    address private admin = 0xd51b4c5483513CF83071fb2E0dF7dbf30c4AC503;

    // 存款记录结构体
    struct Deposit {
        address user;
        uint256 amount;
    }

    // 存款记录数组 
    Deposit[] public deposits;

    receive() external payable {}

    fallback() external payable {}

   // 修饰符：仅允许管理员调用
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    // 提款函数，仅管理员可调用
    function withdraw() public onlyAdmin {
        // 获取合约的余额
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        // 向管理员地址发送全部余额
        payable(admin).transfer(balance);
    }

    // 存款函数，允许用户存款并记录存款信息
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
        // 将存款记录添加到数组中
         if(deposits.length < 3){
            // 创建新的存款记录
            Deposit memory newDeposit = Deposit({
                user: msg.sender,
                amount: msg.value
            });
            deposits.push(newDeposit);
         }
    }

    // 查看前三名用户的账户
    function getDeposit(uint256 index) public view returns (address, uint256) {
        require(index < deposits.length, "Index out of bounds.");
        Deposit storage depositRecord = deposits[index];
        return (depositRecord.user, depositRecord.amount);
    }



}   
