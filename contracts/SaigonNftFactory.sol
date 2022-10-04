// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SaigonNFT is ERC721URIStorage, ERC2981 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    event Minted(string tokenUri);
    
    Counters.Counter public _tokenIds;
    
    constructor() ERC721("SaiGon Districts", "SGN") {}
    
    // / @notice                          Mints the amount of tokens requested by the buyer
    // / @param      tokenIds             The number of NFT already minted in the collection
    // / @return     newTokenId           the total number of NFT minted afterwards to be displayed on UI
    function mint(string calldata _tokenURI) external returns (uint256) {
        
        _tokenIds.increment();
        
        uint256 newTokenId = _tokenIds.current();
       
        _setTokenURI(newTokenId, _tokenURI);
        
        emit Minted(_tokenURI);

        _safeMint(msg.sender, newTokenId);
    
        
        // Payment transferred 
        // (bool success, ) = owner.call{value: msg.value}("");
        // require(success, "Transfer failed");
                
        return newTokenId;  
    }
    
     /**
    @notice Sets the contract-wide royalty info.
     */
    function setRoyaltyInfo(address receiver, uint96 feeBasisPoints)
        external
        /*onlyOwner*/
    {
        _setDefaultRoyalty(receiver, feeBasisPoints);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}    
    

