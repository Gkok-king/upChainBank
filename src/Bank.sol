// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 编写一个 Bank 合约，实现功能：
// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名 的用户

contract Bank {
    // admin 用户
    address private admin = 0xd51b4c5483513CF83071fb2E0dF7dbf30c4AC503;

    // 存款记录map
    mapping (address => uint) depositMap;
    // 存款前三记录数组 
    address[] public deposits;

    receive() external payable {
        deposit();
    }
    fallback() external payable {}


    // 定义错误
    error IndexOutOfBounds(uint256 index, uint256 length);
    error PermissionError(address Address);
    error balanceZero(address Address);

   // 修饰符：仅允许管理员调用
    modifier onlyAdmin() {
        if(msg.sender != admin){
            revert PermissionError(msg.sender);
        }
        _;
    }

    // 提款函数，仅管理员可调用
    function withdraw(uint value) public onlyAdmin {
        // 获取合约的余额
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        // 向管理员地址发送全部余额
        payable(admin).transfer(value);
    }

    // 存款函数，允许用户存款并记录存款信息
    function deposit() public payable {
        if(msg.value > 0){
            revert balanceZero(msg.sender);
        }
        if(deposits.length<3){
            // 将存款记录添加到数组中
            deposits.push(msg.sender);
        }else{
            // 比较方法
            replaceMinValue(msg.sender,msg.value);
        }
        //记录金额
        depositMap[msg.sender] = msg.value;
    }

    // 比较金额
    function replaceMinValue(address user,uint newValue) internal {
        uint minIndex = 0;
        for (uint i = 1; i < deposits.length; i++) {
            if (deposits[i] < deposits[minIndex]) {
                minIndex = i;
            }
        }
        if (newValue > depositMap[deposits[minIndex]]) {
            deposits[minIndex] = user;
        }
    }


    // 查看前三名用户的账户
    function getDeposit(uint256 index) public view returns (address, uint) {
        if(index < deposits.length){
            revert IndexOutOfBounds(index, deposits.length);
        }
        return (deposits[index], depositMap[deposits[index]]);
    }

    
    

}   
