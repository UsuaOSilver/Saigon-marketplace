// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/** 1. Compatible with ERC-721 standard */
contract NFT is ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    
    string  public URI;
    
    uint256 public constant LISTING_PRICE;
    
    uint256 public constant TOTAL_SUPPLY;
    
    uint256 public constant MAX_PURCHASE;
    
    constructor(
                string memory _name, 
                string memory _symbol, 
                string memory _tokenURI, 
                uint256 _price,
                uint256 _totalSupply,
                uint256 _maxPurchase
                ) ERC721(_name, _symbol) {
        URI = _tokenURI;
        LISTING_PRICE = _price;
        TOTAL_SUPPLY = _totalSupply;
        MAX_PURCHASE = _maxPurchase;
    }
    
    function mint(string memory tokenIds, uint256 numTokensPurchase) public payable returns (uint256) {
        uint256 remainingSupply = TOTAL_SUPPLY - _tokenIds.current();
        uint256 totalPrice = numTokensPurchase * LISTING_PRICE;        
        
        require(numTokensPurchase <= MAX_PURCHASE, "Max allowance per tx exceeded");
        require(_tokenIds.current() + numTokensPurchase <= TOTAL_SUPPLY, "Max supply reached");
        require(msg.value >= totalPrice, "Need at least Price*numTokensPurchase ether");
        
        _tokenIds.increment();
        
        uint256 newTokenId = _tokenIds.current();
        
        for (uint i =0; i < numTokensPurchase; i++) {
            _safeMint(msg.sender, newTokenId);
            _setTokenURI(newTokenId, tokenURI);
            createMarketItem(newTokenId, LISTING_PRICE);
        }
        
        return newTokenId;
    }    
    
    //Mint & list function in the same or different contract
    // How to think and design these contracts
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at leat 1 wei");
        require(msg.value == LISTING_PRICE, "Price must be equal to listing price");
        
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
    }
}

