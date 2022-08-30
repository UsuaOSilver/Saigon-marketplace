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
    
    async function laodNFTs() {}
    
    function listNFT(nft) {}
    
    if(loadingState === 'loaded' && !nfts.length) return (<h1 className='py-10 px-20 text-3xl'>No NFTs owned</h1>)
    
    return()
}