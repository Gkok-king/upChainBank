// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 回调函数
interface TokensReceived {

    function tokensReceived(
        address to,
        uint256 amount
    ) external returns(bool);
}   
