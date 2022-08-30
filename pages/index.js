import { ethers } from 'ethers'
import { useEffect, useState } from 'react'
import axios from 'axios'
import Web3Modal from 'web3modal'

import { marketplaceAddress } from '../config'

import SaigonMarket from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'

export default function Home() {
  const [nfts, setNfts] = useState([])
  const [loadingState, setLoadingState] = useState('not-loaded')
  useEffect(() => {
    loadNFTs()
  }, [])
  async function loadNFTs() {
    /** Create a generic provider and query for unsold market items */
    const provider = new ethers.providers.JsonRpcProvider()
    const contract = new ethers.Contract(marketplaceAddress, SaigonMarket.abi, provider)
    const data = await contract.fetchMarketItems()
    
    /* Map over items returned from smart contract and format
     * them as weel as fetch their token metadata
    */
   const items = await Promise.all(data.map(async i => {
    const tokenUri = await contract.tokentURI(i.tokenId)
    const meta = await axios.get(tokenUri)
    let price = ethers.utils.formatUnits(i.price.toString(), 'ether')
    let item = {
      price,
      tokenId: i.tokenId.toNumber(),
      seller: i.seller,
      owner: i.owner,
      image: meta.data.image,
      name: meta.data.name,
      description: meta.data.description,
    }
    return item
   }))
   setNfts(items)
   setLoadingState('loaded')
  }
  async function buyNft(nft) {}
}