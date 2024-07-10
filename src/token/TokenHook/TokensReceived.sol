// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// 回调函数
interface TokensReceived {
    function tokensReceived(
        address from,
        address to,
        uint256 tokenId
    ) external returns (bool);
}
