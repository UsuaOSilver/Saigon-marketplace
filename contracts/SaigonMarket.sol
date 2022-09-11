// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "../contracts/NftFactory.sol";

/// @title Contract of the SaiGon Martketplace
contract SaigonMarket {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;


    /**************/
    /*** Events ***/
    /**************/
    
    event MarketitemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    
    // event ListingSold();
    // event OfferPlaced();
    // event OfferClosed();
    // event Balancedwithdrawned();
    // event TransferOwnership();
    
    
    /***********************/
    /*** State Variables ***/
    /***********************/
    address operator;

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(address => uint) balances;
    
    /// @custom: add address assetContract?
    /// @custom: add English auction: startTime, secondsUntilEndTime, currencyToAccept
    /// @custom: English and GDA in the AuctionHouse contract instead of separated
    /// @custom: add ERC1155 support: quantityToList, reservePricePerToken, buyoutPricePerToken
    /// @custom: add ListingType: directListing, EnglishAuction, GDA
    struct MarketItem {
        address payable seller;
        address payable owner;
        uint256 tokenId;
        uint256 price;
        bool sold;
    }
    
    constructor (address _operator) {
        operator = _operator;
    }
    
    
    /************************/
    /*** Helper Functions ***/
    /************************/
    
    /// @notice Returns the listing price of the contract 
    /// @return Listing price in ether
    // function getListingPrice() public view returns (uint256) {
    //     return listingPrice;
    // }
    
    
    /************************/
    /*** Sell Functions ***/
    /************************/
    
    // / @notice Updates the listing price of the contract 
    // / @params _listingPrice
    // function updateListingPrice(uint _listingPrice) public payable {
    //     require(owner == msg.sender, "Only marketplace owner can update listing price.");
    //     listingPrice = _listingPrice;
    // }
    
    // / @notice Mint a token and list it in the marketplace 
    // / @params tokenURI
    // / @params price
    function createToken(
                        string memory name, 
                        string memory symbol, 
                        string memory tokenURI, 
                        uint256 price,
                        uint256 totalSupply,
                        uint256 maxPurchase
                        ) public payable returns (uint) {
        // _tokenIds.increment();
        // uint256 newTokenId = _tokenIds.current();
        
        // _mint(msg.sender, newTokenId);
        // _setTokenURI(newTokenId, tokenURI);
        // createMarketItem(newTokenId, price);
        
        NFT nft = new NFT(name, symbol, tokenURI, price, totalSupply, maxPurchase);
        
        nft.mint(_tokenIds, numTokensPurchase);
        // return newTokenId;
    }
    
    /// @notice
    /// @params tokenId
    /// @params price
    // function createMarketItem(uint256 tokenId, uint256 price) private {
    //     require(price > 0, "Price must be at leat 1 wei");
    //     require(msg.value == listingPrice, "Price must be equal to listing price");
        
    //     idToMarketItem[tokenId] = MarketItem(
    //         tokenId,
    //         payable(msg.sender),
    //         payable(address(this)),
    //         price,
    //         false
    //     );
    // }
    
    /// @notice Allow someone to resell a token they have purchased 
    /// @params tokenId
    /// @params price
    // function resellToken(uint256 tokenId, uint256 price) public payable {
    //     require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
    //     require(msg.value == listingPrice, "Price must be equal to listing price");
    //     idToMarketItem[tokenId].sold = false;
    //     idToMarketItem[tokenId].price = price;
    //     idToMarketItem[tokenId].seller = payable(msg.sender);
    //     idToMarketItem[tokenId].owner = payable(address(this));
    //     _itemsSold.decrement();
        
    //     _transfer(msg.sender, address(this), tokenId);
    // }
    
    /// @notice Create the sale of a marketplace item. 
    /// @dev Trasnfer ownership of the item, as well as funds between parties 
    /// @params tokenId  The Id of the NFT 
    // function createMarketSale(uint256 tokenId) public payable {
    //     uint price = idToMarketItem[tokenId].price;
    //     address seller = idToMarketItem[tokenId].seller;
    //     require(msg.value == price, "Please submit the asking price in order to complete the purchase");
    //     idToMarketItem[tokenId].owner = payable(msg.sender);
    //     idToMarketItem[tokenId].sold = true;
    //     idToMarketItem[tokenId].seller = payable(address(0));
    //     _itemsSold.increment();
    //     _transfer(address(this), msg.sender, tokenId);
    //     payable(owner).transfer(listingPrice);
    //     payable(seller).transfer(msg.value);
    // }
    
    
    /************************/
    /*** Offer Functions ***/
    /************************/
    
    
    /**********************/
    /*** View Functions ***/
    /**********************/
    
    /// @notice Returns all unsold market items 
    /// @return
    // function fetchMarketItems() public view returns (MarketItem[] memory) {
    //     uint itemCount = _tokenIds.current();
    //     uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
    //     uint currentIndex = 0;
        
    //     MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    //     for(uint i = 0; i < itemCount; i++) {
    //         if (idToMarketItem[i + 1].owner == address(this)) {
    //             uint currentId = i + 1;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentId] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return items;
    // }
    
    /// @notice Returns only the items that the user has purchased 
    /// @return
    // function fetchMyNFTs() public view returns (MarketItem[] memory) {
    //     uint totalItemCount = _tokenIds.current();
    //     uint itemCount = 0;
    //     uint currentIndex = 0;
        
    //     for (uint i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].owner == msg.sender) {
    //             itemCount += 1;
    //         }
    //     }
        
    //     MarketItem[] memory items = new MarketItem[](itemCount);
    //     for (uint i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].owner == msg.sender) {
    //             uint currentId = i + 1;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;            
    //         }
    //     }
    //     return items;
    // }
    
    /// @notice Returns only item a user has listed 
    /// @return
    // function fetchItemsListed() public view returns (MarketItem[] memory) {
    //     uint totalItemCount = _tokenIds.current();
    //     uint itemCount = 0;
    //     uint currentIndex = 0;
        
    //     for (uint i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].seller == msg.sender) {
    //             itemCount += 1;
    //         }
    //     }
        
    //     MarketItem[] memory items = new MarketItem[](itemCount);
    //     for (uint i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].seller == msg.sender) {
    //             uint currentId = i + 1;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return items;
    // }
    
}
