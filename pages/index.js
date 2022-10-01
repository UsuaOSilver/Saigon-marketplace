import { ethers } from 'ethers'
import { useEffect, useState } from 'react'
import axios from 'axios'
import Web3Modal from 'web3modal'
// import ConnectWallet from '@/components/ConnectWallet'
// import ThemeSwitcher from '@/components/ThemeSwitcher'

import SaigonMarketAddress from '../contractsData/SaigonMarket-address.json'
import SaigonMarketAbi from '../contractsData/SaigonMarket.json'
// Copy from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'
import SaigonNFTAddress from '../contractsData/SaigonNFT-address.json'
import SaigonNFTAbi from '../contractsData/SaigonNFT.json'
//Copied from '../artifacts/contracts/SaigonNFTFactory.sol/SaigonNFTFactory.json'
import PriceSaigonMarketAddress from '../contractsData/PriceSaigonMarket-address.json'
import PriceSaigonMarketAbi from '../contractsData/PriceSaigonMarket.json'
//Copied from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'

export default function Home() {
  const [nfts, setNfts] = useState([])
  const [loadingState, setLoadingState] = useState('not-loaded')
  useEffect(() => {
    loadNFTs()
  }, [])
  async function loadNFTs() {
    /** Create a generic provider and query for unsold market listings */
    const provider = new ethers.providers.JsonRpcProvider()
    let nft = new ethers.Contract(SaigonNFTAddress, SaigonNFTAbi.abi, provider)
    let market = new ethers.Contract(SaigonMarketAddress, SaigonMarketAbi.abi, provider)
    let chainlinkPrice = new ethers.Contract(PriceSaigonMarketAddress, PriceSaigonMarketAbi.abi, provider)
    const data = await contract.fetchMarketListings(nft.address)
    
    /* Map over listings returned from smart contract and format
     * them as well as fetch their token metadata
    */
   const listings = await Promise.all(data.map(async i => {
    const tokenUri = await nft.tokentURI(i.tokenId)
    const meta = await axios.get(tokenUri)
    let ethPrice = await market.getPricePerItem(nft.address, i.listingId)
    let ethUsdRate = await chainlinkPrice.getLatestPrice() 
    let usdPrice = ethPrice * ethUsdRate
    let listing = {
      ethPrice,
      usdPrice,
      listingId: i.listingId.toNumber(),
      seller: i.seller,
      owner: i.owner,
      image: meta.data.image,
      name: meta.data.name,
      description: meta.data.description,
    }
    return listing
   }))
   setNfts(listings)
   setLoadingState('loaded')
  }
  async function buyNft(nft) {
    /** Needs the user to sign the transaction, so will use Web3Provider and sign it */
    const web3Modal = new Web3Modal()
    const connection = await web3Modal.connect()
    const provider = new ethers.providers.Web3Provider(connection)
    const signer = provider.getSigner()
    const market = new ethers.Contract(SaigonMarketAddress, SaigonMarketAbi.abi, signer)
    
    /** User will be promted to pay the asking finalPrice to complete the transaction */
    const price = ethers.utils.parseUnits(market.getFinalPrice(nft.address, nft.listingId).toString(), 'ether')
    const transaction = await market.createMarketSale(nft.address, nft.listingId, { value: price })
    await transaction.wait()
    loadNFTs()
  }
  if (loadingState === 'loaded' && !nfts.length) return (<h1 className='px-20 py-10 text-3xl'>No items in marketplace</h1>)
  return (
    <div className='flex justify-center'>
      <div className='px-4' style={{ maxWidth: '1600px' }}>
        <div className='grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4'>
          {
            nfts.map((nft, i) => (
              <div key={i} className='border shadow rounded-xl overflow-hidden'>
                <img src={nft.image} />
                <div className='p-4'>
                  <p style={{ height: '64px' }} className='text-2xl font-semibold'>{nft.name}</p>
                  <div style={{ height: '70px', overflow: 'hidden' }}>
                    <p className='text-gray-400'>{nft.description}</p>
                  </div>
                </div>
                <div className='p-4 bg-black'>
                  <p className='text-2xl font-bold text-white'>{nft.ethPrice} ETH ~ ${nft.usdPrice}</p>
                  <button className='mt-4 w-full bg-pink-500 text-white font-bold py-2 px-12 rounded' onClick={() => buyNft(nft)}>Buy</button>
                </div>
              </div>
            ))
          }
        </div>
      </div>
    </div>
  )
}