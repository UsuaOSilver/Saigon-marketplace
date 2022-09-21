// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error NftFctr__MaxQuantityExceeded();
error NftFctr__MaxSupplyReached();
error NftFctr__NotEnoughFundSent();

/** 1. Compatible with ERC-721 standard */
contract SaigonNFT is ERC721URIStorage, Ownable {
    
    event Minted(
        uint256 tokenId,
        string tokenUri,
        address beneficiary, // Mint user
        address minter // address(this)
    );
    event FundWithdrawn()
    
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
    ) public ERC721(_name, _symbol) {
        URI = _tokenURI;
        LISTING_PRICE = _price;
        TOTAL_SUPPLY = _totalSupply;
        MAX_PURCHASE = _maxPurchase;
    }
    
    /// @notice                          Mints the amount of tokens requested by the buyer
    /// @param      _to                  The NFT buyer address
    /// @param      tokenIds             The number of NFT already minted in the collection
    /// @param      quantityPurchase     The quantity that will be minted based on the order
    /// @return     newTokenId           the total number of NFT minted afterwards to be displayed on UI
    function mint(address _to, string memory tokenIds, uint256 quantityPurchase) external payable returns (uint256) {
        uint256 remainingSupply = TOTAL_SUPPLY - _tokenIds.current();
        uint256 totalPrice = quantityPurchase * LISTING_PRICE;        
        
        require(quantityPurchase <= MAX_PURCHASE, "Max allowance per tx exceeded");
        require(_tokenIds.current() + quantityPurchase <= TOTAL_SUPPLY, "Max supply reached");
        require(msg.value >= totalPrice, "Need at least Price*numTokensPurchase ether");
        
        _tokenIds.increment();
        
        uint256 newTokenId = _tokenIds.current();
        
        for (uint i =0; i < quantityPurchase; i++) {
            _safeMint(msg.sender, newTokenId);
            _setTokenURI(newTokenId, URI);
        }
        
        // Payment transferred 
        (bool success, ) = owner.call{value: msg.value}("");
        require(success, "Transfer failed");
        
        emit Minted(newTokenId, URI, _to, _msgSender())
        
        return newTokenId;  
    }
}    
    

