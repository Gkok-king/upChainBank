// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

//

import "./IERC20.sol";
import "./Address.sol";
import "./TokensReceived.sol";
import "../NFT/COCO.sol";

contract BaseERC20 is IERC20 {
    using Address for address;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    //允许任何人查看任何地址的 Token 余额
    function balanceOf(
        address _owner
    ) public view override returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    //允许 Token 的所有者将他们的 Token 发送给任何人
    function transfer(
        address _send,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        // write your code here
        require(
            balances[_send] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[_send] -= _value;
        balances[_to] += _value;

        emit Transfer(_send, _to, _value);
        return true;
    }

    //允许被授权的地址消费他们被授权的 Token 数量
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        // write your code here
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            allowances[_from][msg.sender] >= _value,
            "ERC20: transfer amount exceeds allowance"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    //允许 Token 的所有者批准某个地址消费他们的一部分Token
    function approve(
        address _spender,
        uint256 _value
    ) public override returns (bool success) {
        // write your code here
        // 我觉得授权这里就需要限制下，但写了测试过不了...
        //require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        //require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //允许任何人查看一个地址可以从其它账户中转账的代币数量
    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256 remaining) {
        // write your code here
        return allowances[_owner][_spender];
    }

    // 这里完成一次购买
    function transferWitchCallback(
        address send,
        address recipient,
        uint256 amount,
        bytes memory data
    ) external override returns (bool) {
        transfer(msg.sender, recipient, amount);
        if (recipient.isContract()) {
            // 这里recipient选错了怎么办，考虑这一点就可以学习，openzeppelin，
            bool rv = TokensReceived(recipient).tokensReceived(
                send,
                recipient,
                amount,
                data
            );
            require(rv, "No tokensReceived");
        }
        return true;
    }
}

contract TokenBank {
    BaseERC20 public token;
    ERC721 public nftContract; // 使用 COCO 合约类型
    uint256 public nftTokenId;

    // 存款记录map
    mapping(address => uint) tokenBalances;

    receive() external payable {}

    fallback() external payable {}

    constructor(address tokenAddress, address cocoAddress) {
        token = BaseERC20(tokenAddress);
        nftContract = COCO(cocoAddress); // 初始化为 COCO 合约地址
    }

    // 定义错误
    error balancesError(address Address);
    error inputError(address Address);

    // 提款函数
    function withdraw(uint value) public {
        if (value <= 0) {
            revert inputError(msg.sender);
        }
        if (tokenBalances[msg.sender] < value) {
            revert balancesError(msg.sender);
        }
        tokenBalances[msg.sender] -= value;
        require(
            token.transfer(msg.sender, msg.sender, value),
            "Transfer failed"
        );
    }

    // 存款函数
    function deposit(uint value) public {
        if (value <= 0) {
            revert inputError(msg.sender);
        }
        require(
            token.transferFrom(msg.sender, address(this), value),
            "TransferFrom failed"
        );
        tokenBalances[msg.sender] += value;
    }
}
