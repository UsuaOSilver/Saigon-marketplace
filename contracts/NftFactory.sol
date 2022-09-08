// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/** 1. Compatible with ERC-721 standard */
contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    
    Counters.Counter private _nftIds;
    
    constructor() ERC721("NFTToken", "NFTT") {}
    
    function mintNft(string memory nftIds) public returns (uint256) {
        _nftIds.increment();
        
        uint256 newNftId = _nftIds.current();
        _safeMint(msg.sender, newNftId);
        _setTokenURI(newNftId, tokenURI);
        
        return newNftId;
    }    
}

