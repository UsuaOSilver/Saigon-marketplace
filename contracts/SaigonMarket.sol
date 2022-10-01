// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../contracts/SaigonNftFactory.sol";


error NotListed(address nftAddress, uint256 listingId);
error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
// error NotEnoughNFTHold();
error AlreadyListed();
error ListingNotExist();
error InvalidNftAddress();
error PriceMustBeAboveZero();
error NotOwner();
error NFTNotApprovedForMarketplace();
error ListingSold();
error TransferFailed();

/// @title Contract of the SaiGon Martketplace
contract SaigonMarket is ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter public _listingIds;
    Counters.Counter private _listingsSold;


    /**************/
    /*** Events ***/
    /**************/
    
    event NFTListed(
        // uint256 indexed listingId,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 pricePerItem,
        bool sold
    ); 
    event NFTListedForResell(
        // uint256 indexed listingId,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 pricePerItem,
        bool sold
    );
    event ListingPurchased(
        address indexed seller,
        address indexed buyer,
        uint256 tokenId,
        // uint256 listingId,
        uint256 pricePerItem,
        bool sold
    );
    // event ListingUpdated(
    //     address indexed owner,
    //     address nft,
    //     uint256 tokenId,
    //     uint256 newPrice
    // );
    // event ListingCancelled(
    //     address indexed nft,
    //     uint256 tokenId
    // );
    // event OfferCreated(
    //     address indexed creator,
    //     address indexed nft,
    //     uint256 tokenId,
    //     uint256 quantity,
    //     uint256 pricePerItem,
    //     uint256 deadline
    // );
    // event OfferCanceled(
    //     address indexed creator,
    //     address indexed nft,
    //     uint256 tokenId
    // );
    // event Balancedwithdrawned();
    // event TransferOwnership();
    
    
    /**************/
    /*** Struct ***/
    /**************/

    /// @notice Structure for listed items    
    struct Listing {
        address payable seller;
        address payable owner;
        IERC721 nft;
        uint256 listingId;
        uint256 tokenId;
        uint256 pricePerItem;
        bool sold;
    }
    
    /// @notice Structure for offer
    struct Offer {
        IERC20 payToken;
        uint256 quantity;
        uint256 pricePerItem;
        uint256 deadline;
    }
    
    struct CollectionRoyalty {
        uint16 royalty;
        address creator;
        address feeRecipient;
    }
    
    
    /*****************/
    /*** Modifier ***/
    /****************/
    
    modifier notListed(
        address nftAddress,
        uint256 tokenId
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (address(this) == owner) {
            revert AlreadyListed();
        }
        _;
    }

    modifier isListed(uint256 listingId) {
        if (listingId <= 0 && listingId > _listingIds.current()) {
            revert ListingNotExist();
        }
        _;
    }
    
    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address seller
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (seller != owner) {
            revert NotOwner();
        }
        _;
    }
    
    
    /***********************/
    /*** State Variables ***/
    /***********************/
    
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;
    
    address payable public immutable operator; // the account that receives fees
    uint public immutable feeBps; // the fee % on sales 

    /// @notice nftAddress -> listingId -> Listing
    mapping(address => mapping(uint256 => Listing)) public listings;
    
    /// @notice listingId -> Offer
    // mapping(address => mapping(uint256 => Offer)) public offers;
    
    /// @notice NFT Address => Bool
    // mapping(address => bool) public exists; // compare INTERFACE_ID instead
    
    
    constructor (uint _feeBps) {
        operator = payable(msg.sender);
        feeBps = _feeBps;
    }
    
    
    /************************/
    /*** Sell Functions ***/
    /************************/
    
    // / @notice Updates the listing price of the contract 
    // / @params _pricePerItem
    // function updatePricePerItem(uint _pricePerItem) public payable {
    //     require(owner == msg.sender, "Only marketplace owner can update listing price.");
    //     pricePerItem = _pricePerItem;
    // }
    
    // / @notice Method for listing NFT
    // / @params _nftAddress token address
    // / @params _tokenId token ID
    function listNFT(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _listingId,
        uint256 _pricePerItem
     ) public {
        
        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721 nft = IERC721(_nftAddress);
            if(nft.ownerOf(_tokenId) != msg.sender) revert NotOwner();
            if (!nft.isApprovedForAll(msg.sender, address(this))) {
                revert NFTNotApprovedForMarketplace();
            }
        } /*else if (
            IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            IERC1155 nft = IERC1155(_nftAddress);
            if (!nft.balanceOf(_msgSender(), _tokenId) >= _quantity) {
                revert NotEnoughNftHold();
            }
            if (!nft.isApprovedForAll(_msgSender(), address(this))) {
                revert NotApprovedForMarketplace();
            }
        }*/ else {
            revert InvalidNftAddress();
        }
                
        listings[_nftAddress][_listingId] = Listing(
            payable(msg.sender),
            payable(address(this)),
            IERC721(_nftAddress),
            _listingId,
            _tokenId,
           _pricePerItem,
           false
        );
    }
    
    // / @notice Mint a token and list it in the marketplace 
    // / @params tokenURI
    // / @params price
    function createListing(
                        address _nftAddress, 
                        uint256 _tokenId,
                        uint256 _pricePerItem
    ) 
        external 
        payable 
        isOwner(_nftAddress, _tokenId, msg.sender)
        notListed(_nftAddress, _tokenId) 
        nonReentrant 
    {
        if(_pricePerItem <= 0) revert PriceMustBeAboveZero();
        
        _listingIds.increment();
        
        uint256 listingId = _listingIds.current();
                        
        /*exists[address(_nft)] = true;*/
        listNFT(_nftAddress, _tokenId, listingId, _pricePerItem);
        
        IERC721(_nftAddress).transferFrom(msg.sender, address(this), _tokenId);
        
        emit NFTListed(
            // listingId,
            _nftAddress,
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
           _pricePerItem,
           false
        );
    }
    
    // / @notice Allow someone to resell a token they have purchased 
    // / @params tokenId token ID
    // / @params _pricePerItem listing price
    function resellNFT(address _nftAddress, uint256 _listingId, uint256 _pricePerItem) 
        external 
        payable 
        isOwner(_nftAddress, listings[_nftAddress][_listingId].tokenId, msg.sender)
        notListed(_nftAddress, listings[_nftAddress][_listingId].tokenId) 
        nonReentrant 
    {
        if(_pricePerItem <= 0) revert PriceMustBeAboveZero();
        uint _finalPrice = getFinalPrice(_nftAddress, _listingId);
        Listing memory listing = listings[_nftAddress][_listingId];
        listing.sold = false;
        listing.pricePerItem = _pricePerItem;
        listing.seller = payable(msg.sender);
        listing.owner = payable(address(this));
        _listingsSold.decrement();
        
        listing.nft.transferFrom(msg.sender, address(this), listing.tokenId);
        
        uint256 newPrice = _pricePerItem;
        
        emit NFTListedForResell(
            // _listingId,
            _nftAddress,
            listing.tokenId,
            payable(msg.sender),
            payable(address(this)),
            newPrice,
            false
        );
    }
    
    // / @notice Create the sale of a marketplace item. 
    // / @dev Trasnfer ownership of the item, as well as funds between parties 
    // / @params tokenId  The Id of the NFT 
    function createMarketSale(address _nftAddress, uint256 _listingId) 
        external 
        payable 
        isListed(_listingId)
        nonReentrant 
    {
        uint _finalPrice = getFinalPrice(_nftAddress, _listingId);
        Listing memory listing = listings[_nftAddress][_listingId];
        uint price = listing.pricePerItem;
        uint fee = _finalPrice - price;
        address seller = listing.seller;
        if(msg.value < _finalPrice) revert PriceNotMet(_nftAddress, listing.tokenId, _finalPrice);
        if(listing.sold) revert ListingSold();
        listing.owner = payable(msg.sender);
        listing.sold = true;
        seller = payable(address(0));
        _listingsSold.increment();
        listing.nft.safeTransferFrom(address(this), msg.sender, listing.tokenId);
        
        // Safe transfer Cost and Fee
        (bool success, ) = seller.call{value: price}("");
        if(!success) revert TransferFailed();
        (bool _success, ) = operator.call{value: fee}("");
        if(!_success) revert TransferFailed();
        
        emit ListingPurchased(
            seller,
            msg.sender,
            listing.tokenId,
            // _listingId,
            price,
            true
        );
    }
    
    
    /************************/
    /*** Offer Functions ***/
    /************************/
    
    
    /**********************/
    /*** View Functions ***/
    /**********************/
    
    // / @notice Returns all unsold market items 
    // / @return all market items
    function fetchMarketListings(address _nftAddress) public view returns (Listing[] memory) {
        uint listingCount = _listingIds.current();
        uint unsoldListingCount = _listingIds.current() - _listingsSold.current();
        uint currentIndex = 0;
        
        Listing[] memory nftListings = new Listing[](unsoldListingCount);
        for(uint i = 0; i < listingCount; i++) {
            if (listings[_nftAddress][i + 1].seller == address(this)) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[_nftAddress][currentId];
                nftListings[currentId] = currentListing;
                currentIndex += 1;
            }
        }
        return nftListings;
    }
    
    // / @notice Returns only the items that the user has purchased 
    // / @return all NFTs of the user that are not listed on the market
    function fetchMyNFTs(address _nftAddress) public view returns (Listing[] memory) {
        uint totalListingCount = _listingIds.current();
        uint listingCount = 0;
        uint currentIndex = 0;
        
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[_nftAddress][i + 1].seller == msg.sender) {
                listingCount += 1;
            }
        }
        
        Listing[] memory nftListings = new Listing[](listingCount);
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[_nftAddress][i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[_nftAddress][currentId];
                nftListings[currentIndex] = currentListing;
                currentIndex += 1;            
            }
        }
        return nftListings;
    }
    
    // / @notice Returns only item a user has listed 
    // / @return all NFTs of the user that are listed on the market
    function fetchOwnedListings(address _nftAddress) public view returns (Listing[] memory) {
        uint totalListingCount = _listingIds.current();
        uint listingCount = 0;
        uint currentIndex = 0;
        
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[_nftAddress][i + 1].seller == msg.sender) {
                listingCount += 1;
            }
        }
        
        Listing[] memory nftListings = new Listing[](listingCount);
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[_nftAddress][i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[_nftAddress][currentId];
                nftListings[currentIndex] = currentListing;
                currentIndex += 1;
            }
        }
        return nftListings;
    }
    
       
    /************************/
    /*** Helper Functions ***/
    /************************/
    
    // / @notice Returns the final price, which is the total of the listing price and the marketplace fee
    // / @return Total price in ether
    function getFinalPrice(address _nftAddress, uint _listingId) public view returns (uint256) {
        return ((listings[_nftAddress][_listingId].pricePerItem*(100 + feeBps))/100);
    } 
    
    function getPricePerItem(address _nftAddress, uint _listingId) public view returns (uint256) {
        return listings[_nftAddress][_listingId].pricePerItem;
    }
    
    
    /************************/
    /** Internal & Private **/
    /************************/
    
    // function _getNow() internal view virtual returns (uint256) {
    //     return block.timestamp;
    // }

    // function _validOwner(
    //     address _nftAddress,
    //     uint256 _tokenId,
    //     address _owner
    //     /*uint256 quantity*/
    // ) internal {
    //     if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
    //         IERC721 nft = IERC721(_nftAddress);
    //         require(nft.ownerOf(_tokenId) == _owner, "not owning item");
    //     } /*else if (
    //         IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155)
    //     ) {
    //         IERC1155 nft = IERC1155(_nftAddress);
    //         require(
    //             nft.balanceOf(_owner, _tokenId) >= quantity,
    //             "not owning item"
    //         );
    //     }*/ else {
    //         revert("invalid nft address");
    //     }
    // }

    // function _cancelListing(
    //     address _nftAddress,
    //     uint256 _tokenId
    // ) private {
    //     Listing memory listedItem = listings[_nftAddress][_tokenId];

    //     _validOwner(_nftAddress, _tokenId, _owner/*, listedItem.quantity*/);

    //     delete (listings[_nftAddress][_tokenId]);
    //     emit ListingCancelled(_nftAddress, _tokenId);
    // }
}
