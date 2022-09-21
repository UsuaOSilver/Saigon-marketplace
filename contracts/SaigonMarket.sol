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
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../contracts/SaigonNftFactory.sol";

error NotOwner();
error NotApprovedForMarketplace();
error NotEnoughNftHold();
error InvalidNftAddress();

/// @title Contract of the SaiGon Martketplace
contract SaigonMarket is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;


    /**************/
    /*** Events ***/
    /**************/
    
    event NFTCreated(address creator, address nft);
    event NFTListed(
        address indexed nft,
        uint256 pricePerItem
    );
    event ListingSold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        int256 unitPrice,
        uint256 pricePerItem
    );
    event ListingUpdated(
        address indexed owner,
        address[] nft,
        uint256[] tokenId,
        address payToken,
        uint256 newPrice
    );
    event ListingCancelled(
        address indexed nft,
        uint256 tokenId
    );
    event OfferCreated(
        address indexed creator,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem,
        uint256 deadline
    );
    event OfferCanceled(
        address indexed creator,
        address indexed nft,
        uint256 tokenId
    );
    // event Balancedwithdrawned();
    // event TransferOwnership();
    
    
    /**************/
    /*** Struct ***/
    /**************/

    /// @notice Structure for listed items    
    struct Listing {
        address[] nfts;
        uint256[] tokenIds;
        uint256 quantity;
        uint256 pricePerItem;
        address payToken;
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
        address _nftAddress,
        uint256 _tokenId
    ) {
         Listing memory listing = listings[_nftAddress][_tokenId];
        require(listing.quantity == 0, "already listed");
        _;
    }
    
    
    /***********************/
    /*** State Variables ***/
    /***********************/
    
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;
   
    address operator;

    /// @notice nftAddress -> tokenId -> Listing
    mapping(address => mapping(uint256 => MarketItem)) public listings;
    
    /// @notice nftAddress -> tokenId -> Offer
    mapping(address => mapping(uint256 => Offer)) public offers;
    
    /// @notice NFT Address => Bool
    mapping(address => bool) public exists;
    
    
    constructor (address _operator) {
        operator = _operator;
    }
    
    
    /************************/
    /*** Sell Functions ***/
    /************************/
    
    // / @notice Updates the listing price of the contract 
    // / @params _pricePerItem
    function updatePricePerItem(uint _pricePerItem) public payable {
        require(owner == msg.sender, "Only marketplace owner can update listing price.");
        pricePerItem = _pricePerItem;
    }
    
    // / @notice Mint a token and list it in the marketplace 
    // / @params tokenURI
    // / @params price
    function createNFT(
                        string memory _name, 
                        string memory _symbol, 
                        string memory tokenURI, 
                        uint256 price,
                        uint256 totalSupply,
                        uint256 maxPurchase
                        ) external payable returns (address) {
        
        SaigonNFT nft = new SaigonNFT(_name, _symbol, tokenURI, price, totalSupply, maxPurchase);
        
        exists[address(nft)] = true;
        nft.TransferOwnership(_msgSender());
        emit NFTCreated(_msgSender(), address(nft));
        return (address(nft));
    }
    
    // / @notice Method for listing NFT
    // / @params _nftAddress token address
    // / @params _pricePerItem listing price
    function listNFT(
        address _nftAddress,
        uint256 _pricePerItem
     ) external notListed(_nftAddress, _tokenId) {
        
        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721 nft = IERC721(_nftAddress);
            if(!nft.ownerOf(_tokenId) == _msgSender()) revert NotOwner();
            if (!nft.isApprovedForAll(_msgSender(), address(this))) {
                revert NotApprovedForMarketplace();
            }
        } else if (
            IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            IERC1155 nft = IERC1155(_nftAddress);
            if (!nft.balanceOf(_msgSender(), _tokenId) >= _quantity) {
                revert NotEnoughNftHold();
            }
            if (!nft.isApprovedForAll(_msgSender(), address(this))) {
                revert NotApprovedForMarketplace();
            }
        } else {
            revert InvalidNftAddress();
        }
                
        listings[_nftAddress][_tokenId] = Listing(
            _quantity,
           _pricePerItem
        );
        emit ItemListed(
            _nftAddress,
           _pricePerItem
        );
    }
    
    // / @notice Allow someone to resell a token they have purchased 
    // / @params tokenId token ID
    // / @params _pricePerItem listing price
    function resellToken(uint256 tokenId, uint256 _pricePerItem) public payable {
        require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
        require(msg.value == pricePerItem, "Price must be equal to listing price");
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();
        
        _transfer(msg.sender, address(this), tokenId);
    }
    
    // / @notice Create the sale of a marketplace item. 
    // / @dev Trasnfer ownership of the item, as well as funds between parties 
    // / @params tokenId  The Id of the NFT 
    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(pricePerItem);
        payable(seller).transfer(msg.value);
    }
    
    
    /************************/
    /*** Offer Functions ***/
    /************************/
    
    
    /**********************/
    /*** View Functions ***/
    /**********************/
    
    // / @notice Returns all unsold market items 
    // / @return all market items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint currentIndex = 0;
        
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for(uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentId] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
    
    // / @notice Returns only the items that the user has purchased 
    // / @return all NFTs of the user that are not listed on the market
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;            
            }
        }
        return items;
    }
    
    // / @notice Returns only item a user has listed 
    // / @return all NFTs of the user that are listed on the market
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }
        
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
    
       
    /************************/
    /*** Helper Functions ***/
    /************************/
    
    // / @notice Returns the listing price of the contract 
    // / @return Listing price in ether
    function getPricePerItem() public view returns (uint256) {
        return pricePerItem;
    }
    
    
    /************************/
    /** Internal & Private **/
    /************************/
    
    function _getNow() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    // function _validPayToken(address _payToken) internal {
    //     require(
    //         _payToken == address(0) ||
    //             (addressRegistry.tokenRegistry() != address(0) &&
    //                 IFantomTokenRegistry(addressRegistry.tokenRegistry())
    //                     .enabled(_payToken)),
    //         "invalid pay token"
    //     );
    // }

    function _validOwner(
        address _nftAddress,
        uint256 _tokenId,
        address _owner,
        uint256 quantity
    ) internal {
        if (IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721 nft = IERC721(_nftAddress);
            require(nft.ownerOf(_tokenId) == _owner, "not owning item");
        } else if (
            IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            IERC1155 nft = IERC1155(_nftAddress);
            require(
                nft.balanceOf(_owner, _tokenId) >= quantity,
                "not owning item"
            );
        } else {
            revert("invalid nft address");
        }
    }

    function _cancelListing(
        address _nftAddress,
        uint256 _tokenId
    ) private {
        Listing memory listedItem = listings[_nftAddress][_tokenId];

        _validOwner(_nftAddress, _tokenId, _owner, listedItem.quantity);

        delete (listings[_nftAddress][_tokenId]);
        emit ListingCancelled(_owner, _nftAddress, _tokenId);
    }
}
