// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SaigonMarket is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    
    uint256 public listingPrice = 0.25 ether;
    address payable public owner;
    
    mapping(uint256 => MarketItem) private idToMarketItem;
    
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    
    event MarketitemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    
    constructor() ERC721("Moi Token", "DONG") {
        owner = payable(msg.sender);
    }
    
    /** Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable onlyOwner {
        listingPrice = _listingPrice;
    }
    
    /** Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }
    
    /** Mint a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }
    
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at leat 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
    }
    
    /** Allow someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();
        
        _transfer(msg.send, address(this), tokenId);
    }
    
    /** Create the sale of a marketplace item.
      * Trasnfer ownership of the item, as well as funds between parties 
      */
    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(seller).transfer(msg.value);
    }
    
    /** Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {}
    
    /** Returns only the items that the user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {}
    
    /** Returns only item a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {}
    
}
