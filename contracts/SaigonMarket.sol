// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SaigonMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemdSold;
    
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
    
    event MarketitemCreated();
    
    constructor() ERC721("Metaverse Token", "METT") {}
    
    /** Updates the listing price of the contract */
    function updateListingPrice() public view returns (uint256) {}
    
    /** Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {}
    
    /** Mint a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {}
    
    function createMarketItem(uint256 tokenId, uint256 price) private {}
    
    /** Allow someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {}
    
    /** Create the sale of a marketplace item.
      * Trasnfer ownership of the item, as well as funds between parties 
      */
    function createMarketSale(uint256 tokenId) public payable {}
    
    /** Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {}
    
    /** Returns only the items that the user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {}
    
    /** Returns only item a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {}
    
}
