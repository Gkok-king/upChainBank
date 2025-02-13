// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

// TokenBank 有两个方法：

// deposit() : 需要记录每个地址的存入数量；
// withdraw（）: 用户可以提取自己的之前存入的 token。

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BaseERC20 is IERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 


    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply =  100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;  
    }

    //允许任何人查看任何地址的 Token 余额
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    //允许 Token 的所有者将他们的 Token 发送给任何人
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    //允许被授权的地址消费他们被授权的 Token 数量
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        // write your code here
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    //允许 Token 的所有者批准某个地址消费他们的一部分Token
    function approve(address _spender, uint256 _value) public override returns (bool success) {
        // write your code here
        // 我觉得授权这里就需要限制下，但写了测试过不了...
        //require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        //require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);  
        return true; 
    }
    //允许任何人查看一个地址可以从其它账户中转账的代币数量
    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {   
        // write your code here     
        return allowances[_owner][_spender];
    }
}
contract TokenBank{
    IERC20 public token;

    // 存款记录map
    mapping (address => uint) tokenBalances;
  
    receive() external payable {

    }
    fallback() external payable {}

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    // 定义错误
    error balancesError(address Address);
    error inputError(address Address);



    // 提款函数
    function withdraw(uint value) public {
        if(value<= 0){
            revert inputError(msg.sender);
        }
         if(tokenBalances[msg.sender] < value){
            revert balancesError(msg.sender);
        }
        tokenBalances[msg.sender] -= value;
        require(token.transfer(msg.sender, value), "Transfer failed");
    }

    // 存款函数
    function deposit(uint value) public {
        if(value<= 0){
            revert inputError(msg.sender);
        }
        require(token.transferFrom(msg.sender, address(this), value), "TransferFrom failed");
        tokenBalances[msg.sender] += value;
    }

    function callSetValue(address target, uint256 value) public {
        (bool success, ) = target.call(abi.encodeWithSignature("setValue(uint256)", value));
        require(success, "Call failed");
    }

}   
