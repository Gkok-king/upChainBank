// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 要求存款金额 >0.001 ether（用modifier权限控制）
// BigBank 合约支持转移管理员
// 同时编写一个 Ownable 合约，把 BigBank 的管理员转移给Ownable 合约， 实现只有Ownable 可以调用 BigBank 的 withdraw().
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

interface Ibank {
    // 取款
    function withdraw(uint amount) external;

}

contract Bank is Ibank {
    // admin 用户
    address internal admin;

    // 存款记录map
    mapping (address => uint) depositMap;
    // 存款前三记录数组 
    address[] public deposits;

    receive() external payable {
        deposit();
    }
    fallback() external payable {}

    // 生成管理员
    constructor() {
        admin = msg.sender;
    }


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
    function withdraw(uint value) public override onlyAdmin {
        // 取和存的钱不能为0
        if(value == 0 || address(this).balance == 0){
            revert balanceZero(msg.sender);
        }

        // 向管理员地址发送余额
        payable(admin).transfer(value);
    }

    // 存款函数，允许用户存款并记录存款信息
    function deposit() public virtual  payable {
        if(msg.value == 0){
            revert balanceZero(msg.sender);
        }
        if(deposits.length < 3 &&  checkAddress() ){
            // 将存款记录添加到数组中
            deposits.push(msg.sender);
        }else{
            // 比较方法 保证金额前三
            replaceMinValue(msg.sender,msg.value);
        }
        //记录具体地址金额
        depositMap[msg.sender] += msg.value;
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

    // 防止记录重复用户
    function checkAddress() internal view returns(bool) {
        if(deposits.length > 0){
            for (uint i = 0; i < deposits.length; i++) {
                if(deposits[i] == msg.sender){
                    return false;
                }
            }
        }
        return true;
    }


    // 查看前三名用户的账户
    function getDeposit(uint256 index) public view returns (address, uint) {
        if(index > deposits.length){
                revert IndexOutOfBounds(index, deposits.length);
        }
        return (deposits[index], depositMap[deposits[index]]);
    }
}   



contract BigBank is Bank {

    error  moneyIsTooLess(uint amount);
    uint256 constant MINIMUM_DEPOSIT = 0.001 ether;

    // 初始化时把 先是自己
    constructor() {
        admin = msg.sender; 
    }
 
    // 限制最小金额
    modifier limitAmount( uint amount) {
        if (amount < MINIMUM_DEPOSIT) {
            revert moneyIsTooLess(amount);
        }
        _;
    }

    // 重用父类方法
    function deposit() public payable override limitAmount(msg.value){
        super.deposit();
    }
    
    // 转移权限
    function transferAdmin(address otherAdmin) public onlyAdmin() {
        admin = otherAdmin;
    }

}   


contract Ownable  {
    address owner;
    BigBank public b;

    constructor(BigBank bigBank){
        b = bigBank;
        owner = msg.sender;
    }
    receive() external payable {}

    // 提取BigBank的钱到合约
    function withdraw(uint amount) public {
        b.withdraw(amount);
    }

    //合约部署的人自己提
    function ownerWithdraw(uint amount) public {
        require(owner == msg.sender, "stop");
        payable(owner).transfer(amount);
    }
}

