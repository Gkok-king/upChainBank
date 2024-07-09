// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract COCO is ERC721, Ownable {
    // 自定义错误
    error TokenNonexistent(uint256 tokenId);
    error ZeroAddress();

    // toekn的Id的计数
    uint256 private tokenIdCounter;
    // ntf的数量
    uint256 private totalSupply;
    // token的id 和地址
    mapping(uint256 => string) private tokenURIs;

    constructor() ERC721("foolCOCO", "CC") Ownable(msg.sender) {
        totalSupply = 0;
    }

    function mint(address to, string memory _tokenURI) public onlyOwner {
        uint256 tokenId = tokenIdCounter;
        tokenIdCounter += 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual {
        if (_ownerOf(tokenId) == address(0)) {
            revert TokenNonexistent(tokenId);
        }
        tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) {
            revert TokenNonexistent(tokenId);
        }
        string memory _tokenURI = tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }
}
