import { ethers } from 'ethers'
import { useEffect, useState } from 'react'
import axios from 'axios'
import Web3Modal from 'web3modal'
import { useRouter } from 'next/router'

import SaigonMarketAddress from '../contractsData/SaigonMarket-address.json'
import SaigonMarketAbi from '../contractsData/SaigonMarket.json'
// Copy from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'
import SaigonNFTAddress from '../contractsData/SaigonNFT-address.json'
import SaigonNFTAbi from '../contractsData/SaigonNFT.json'
//Copied from '../artifacts/contracts/SaigonNFTFactory.sol/SaigonNFTFactory.json'


// Display the NFTs owned by the user
export default function MyAssets() {
    const [nfts, setNfts] = useState([])
    const [loadingState, setLoadingState] = useState('not-loaded')
    const router = useRouter()
    useEffect(() => {
        loadNFTs()
    }, [])
    
    async function loadNFTs() {
        const web3Modal = new Web3Modal({
            network: "mainet",
            cacheProvider: true,
        })
        const connection = await web3Modal.connect()
        const provider = new ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()
            
        let nft = new ethers.Contract(SaigonNFTAddress, SaigonNFTAbi.abi, provider)
        const market = new ethers.Contract(SaigonMarketAddress, SaigonMarketAbi.abi, signer)
        const data = await market.fetchMyNFTs(nft.address)
        
        const listings = await Promise.all(data.map(async i => {
            const tokenURI = await nft.tokenURI(i.tokenId)
            const meta = await axios.get(tokenURI)
            let price = ethers.utils.formatUnits(i.price.toString(), 'ether')
            let listing = {
                price,
                tokenId: i.tokenId.toNumber(),
                seller: i.seller,
                owner: i.owner,
                image: meta.data.image,
                tokenURI
            }
            return listing
        }))
        setNfts(listings)
        setLoadingState('loaded')
    }
    
    function listNFT(nft) {
        router.push(`/resell-nft?id=${nft.tokenId}&tokenURI=${nft.tokenURI}`)
    }
    
    if(loadingState === 'loaded' && !nfts.length) return (<h1 className='py-10 px-20 text-3xl'>No NFTs owned</h1>)
    
    return(
        <div className='flex justify-center'>
            <div className='p-4'>
                <div className='grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4'>
                    {
                        nfts.map((nft, i) => (
                            <div key={i} className="border shadow rounded-xl overflow-hidden">
                                <img src={nft.image} className="rounded" />
                                <div className='p-4 bg-black'>
                                    <p className='text-2xl font-bold text-white'>Price - {nft.price} ETH</p>
                                    <button className='mt-4 w-full bg-pinkn-500 text-white font-bold py-2 px-12 rounded' onClick={() => listNFT(nft)}>List</button>
                                </div>
                            </div>
                        ))
                    }
                </div>
            </div>
        </div>
    )
}