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
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../contracts/SaigonNftFactory.sol";

error NotOwner();
error NotApprovedForMarketplace();
error NotEnoughNFTHold();
error InvalidNftAddress();
error PaymentAmountUnmatched();
error ListingNotAvailable();
error TransferFailed();
error ListingDoesNotExist();

/// @title Contract of the SaiGon Martketplace
contract SaigonMarket is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _listingIds;
    Counters.Counter private _listingsSold;


    /**************/
    /*** Events ***/
    /**************/
    
    event NFTCreated(address creator, address nft);
    event NFTListed(
        uint256 indexed listingId,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 pricePerItem,
        bool sold
    );
    event ListingSold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 listingId,
        uint256 pricePerItem,
        bool sold
    );
    // event ListingUpdated(
    //     address indexed owner,
    //     address nft,
    //     uint256 tokenId,
    //     uint256 newPrice
    // );
    event ListingCancelled(
        address indexed nft,
        uint256 tokenId
    );
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
    // modifier notListed(
    //     address _nftAddress,
    //     uint256 _listingId
    // ) {
    //     Listing memory listing = listings[_nftAddress][_listingId];
    //     require(listings.quantity == 0, "already listed");
    //     _;
    // }
    
    
    /***********************/
    /*** State Variables ***/
    /***********************/
    
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;
    
    address payable owner;
    address payable public immutable feeReceiver; // the account that receives fees
    uint public immutable feeBps; // the fee % on sales 

    /// @notice listingId -> Listing
    mapping(uint256 => Listing) public listings;
    
    /// @notice listingId -> Offer
    mapping(uint256 => Offer) public offers;
    
    /// @notice NFT Address => Bool
    // mapping(address => bool) public exists; // compare INTERFACE_ID instead
    
    
    constructor (uint _feeBps) {
        owner = payable(msg.sender);
        feeReceiver = payable(msg.sender);
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
     ) public /*notListed(_nftAddress, _tokenId)*/ {
        
        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721 nft = IERC721(_nftAddress);
            if(nft.ownerOf(_tokenId) != msg.sender) revert NotOwner();
            if (!nft.isApprovedForAll(msg.sender, address(this))) {
                revert NotApprovedForMarketplace();
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
                
        listings[_listingId] = Listing(
            payable(msg.sender),
            payable(address(0)),
            IERC721(_nftAddress),
            _listingId,
            _tokenId,
           _pricePerItem,
           false
        );
        
        Listing memory listing = listings[_listingId];
        
        listing.nft.transferFrom(msg.sender, address(this), listing.tokenId);
        
        emit NFTListed(
            _listingId,
            _nftAddress,
            _tokenId,
            payable(msg.sender),
            payable(address(0)),
           _pricePerItem,
           false
        );
    }
    
    // / @notice Mint a token and list it in the marketplace 
    // / @params tokenURI
    // / @params price
    function createNFTListing(
                        IERC721 _nft, 
                        uint256 _tokenId,
                        uint256 _pricePerItem
    ) external payable nonReentrant {
                            
        _listingIds.increment();
        uint256 listingId = _listingIds.current();
        address nft = address(_nft);                         
                
        /*exists[address(_nft)] = true;*/
        listNFT(nft, _tokenId, listingId, _pricePerItem);
        emit NFTCreated(msg.sender, nft);
    }
    
    // / @notice Allow someone to resell a token they have purchased 
    // / @params tokenId token ID
    // / @params _pricePerItem listing price
    function resellToken(uint256 _listingId, uint256 _pricePerItem) external payable nonReentrant {
        uint _finalPrice = getFinalPrice(_listingId);
        Listing memory listing = listings[_listingId];
        if(listing.owner != msg.sender) revert NotOwner();
        if(msg.value != _finalPrice) revert PaymentAmountUnmatched();
        listing.sold = false;
        listing.pricePerItem = _pricePerItem;
        listing.seller = payable(msg.sender);
        listing.owner = payable(address(this));
        _listingsSold.decrement();
        
        listing.nft.transferFrom(msg.sender, address(this), listing.tokenId);
    }
    
    // / @notice Create the sale of a marketplace item. 
    // / @dev Trasnfer ownership of the item, as well as funds between parties 
    // / @params tokenId  The Id of the NFT 
    function createMarketSale(uint256 _listingId) external payable nonReentrant {
        uint _finalPrice = getFinalPrice(_listingId);
        Listing memory listing = listings[_listingId];
        uint price = listing.pricePerItem;
        uint fee = _finalPrice - price;
        address seller = listing.seller;
        if(_listingId <= 0 && _listingId > _listingIds.current()) revert ListingDoesNotExist();
        if(msg.value != _finalPrice) revert PaymentAmountUnmatched();
        if(listing.sold) revert ListingNotAvailable();
        listing.owner = payable(msg.sender);
        listing.sold = true;
        seller = payable(address(0));
        _listingsSold.increment();
        listing.nft.transferFrom(address(this), msg.sender, listing.tokenId);
        
        // Transfer Cost and Fee
        (bool success, ) = seller.call{value: price}("");
        if(!success) revert TransferFailed();
        (bool _success, ) = feeReceiver.call{value: fee}("");
        if(!_success) revert TransferFailed();
    }
    
    
    /************************/
    /*** Offer Functions ***/
    /************************/
    
    
    /**********************/
    /*** View Functions ***/
    /**********************/
    
    // / @notice Returns all unsold market items 
    // / @return all market items
    function fetchMarketListings() public view returns (Listing[] memory) {
        uint listingCount = _listingIds.current();
        uint unsoldListingCount = _listingIds.current() - _listingsSold.current();
        uint currentIndex = 0;
        
        Listing[] memory nftListings = new Listing[](unsoldListingCount);
        for(uint i = 0; i < listingCount; i++) {
            if (listings[i + 1].seller == address(this)) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[currentId];
                nftListings[currentId] = currentListing;
                currentIndex += 1;
            }
        }
        return nftListings;
    }
    
    // / @notice Returns only the items that the user has purchased 
    // / @return all NFTs of the user that are not listed on the market
    function fetchMyNFTs() public view returns (Listing[] memory) {
        uint totalListingCount = _listingIds.current();
        uint listingCount = 0;
        uint currentIndex = 0;
        
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[i + 1].seller == msg.sender) {
                listingCount += 1;
            }
        }
        
        Listing[] memory nftListings = new Listing[](listingCount);
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[currentId];
                nftListings[currentIndex] = currentListing;
                currentIndex += 1;            
            }
        }
        return nftListings;
    }
    
    // / @notice Returns only item a user has listed 
    // / @return all NFTs of the user that are listed on the market
    function fetchOwnedListings() public view returns (Listing[] memory) {
        uint totalListingCount = _listingIds.current();
        uint listingCount = 0;
        uint currentIndex = 0;
        
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[i + 1].seller == msg.sender) {
                listingCount += 1;
            }
        }
        
        Listing[] memory nftListings = new Listing[](listingCount);
        for (uint i = 0; i < totalListingCount; i++) {
            if (listings[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                Listing storage currentListing = listings[currentId];
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
    function getFinalPrice(uint _listingId) public view returns (uint256) {
        return ((listings[_listingId].pricePerItem*(100 + feeBps))/100);
    } 
    
    function getPricePerItem(uint _listingId) public view returns (uint256) {
        return listings[_listingId].pricePerItem;
    }
    
    
    /************************/
    /** Internal & Private **/
    /************************/
    
    function _getNow() internal view virtual returns (uint256) {
        return block.timestamp;
    }

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
