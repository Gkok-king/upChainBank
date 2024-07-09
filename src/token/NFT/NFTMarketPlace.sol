// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./COCO.sol";

// //编写一个简单的 NFT市场合约，使用自己的发行的 Token 来买卖 NFT， 函数的方法有：

// list() : 实现上架功能，NFT 持有者可以设定一个价格（需要多少个 Token 购买该 NFT）并上架 NFT 到 NFT 市场。
// buyNFT() : 实现购买 NFT 功能，用户转入所定价的 token 数量，获得对应的 NFT。
contract NFTMarketPlace {
    IERC20 public token;
    COCO public nft;

    struct Listing {
        uint256 price;
        address seller;
    }

    mapping(uint256 => Listing) public listings;

    event NFTListed(
        uint256 indexed tokenId,
        uint256 price,
        address indexed seller
    );
    event NFTBought(
        uint256 indexed tokenId,
        uint256 price,
        address indexed buyer,
        address indexed seller
    );

    constructor(IERC20 _token, COCO _nft) {
        token = _token;
        nft = _nft;
    }

    function list(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be greater than zero");

        nft.transferFrom(msg.sender, address(this), tokenId);

        listings[tokenId] = Listing({price: price, seller: msg.sender});

        emit NFTListed(tokenId, price, msg.sender);
    }

    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed for sale");

        require(
            token.transferFrom(msg.sender, listing.seller, listing.price),
            "Token transfer failed"
        );

        nft.transferFrom(address(this), msg.sender, tokenId);

        delete listings[tokenId];

        emit NFTBought(tokenId, listing.price, msg.sender, listing.seller);
    }
}
