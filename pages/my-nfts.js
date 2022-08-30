import { ethers } from 'ethers'
import { useEffect, useState } from 'react'
import axios from 'axios'
import Web3Modal from 'web3modal'
import { useRouter } from 'next/router'

import { marketplaceAddress } from '../config'

import SaigonMarket from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'

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
        const provider = await ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()
            
        const marketplaceContract = new ethers.Contract(marketplaceAddress, SaigonMarket.abi, signer)
        const data = await marketplaceContract.fetchMyNFTs()
        
        const items = await Promise.all(data.map(async i => {
            const tokenURI = await marketplaceContract.tokenURI(i.tokenId)
            const meta = await axios.get(tokenURI)
            let price = ethers.utils.formatUnits(i.price.toString(), 'ether')
            let item = {
                price,
                tokenId: i.tokenId.toNumber(),
                seller: i.seller,
                owner: i.owner,
                image: meta.data.image,
                tokenURI
            }
            return item
        }))
        setNfts(items)
        setLoadingState('loaded')
    }
    
    function listNFT(nft) {
        router.push(`/resell-nft?id=${nft.tokenId}&tokenURI=${nft.tokenURI}`)
    }
    
    if(loadingState === 'loaded' && !nfts.length) return (<h1 className='py-10 px-20 text-3xl'>No NFTs owned</h1>)
    
    return()
}