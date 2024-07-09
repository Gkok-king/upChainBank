// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC721 {
    function name() external pure returns (address _name);

    function symbol() external pure returns (address _symbol);

    function tokenURI(uint256 _tokenId) external view returns (address);

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function approve(address _approved, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool);
}
