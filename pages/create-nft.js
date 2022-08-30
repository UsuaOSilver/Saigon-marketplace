import { useState } from "react"
import { ethers } from 'ethers'
import { create as ipfsHttpClient } from 'ipfs-http-client'
import { useRouter } from 'next/router'
import Web3Modal from 'web3modal'

const client = ipfsHttpClient('https://ipfs.infura.io:5001/api/v0')

import { marketplaceAddress } from '../config'

import SaigonMarket from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'

export default function CreateIitem() {
    const[fileUrl, setFileUrl] = useState(null)
    const [formInput, updateFormInput] = useState({ price: '', name: '', description: ''})
    const router = useRouter()
    
    async function onChange(e){}
    
    async function uploadToIPFS() {}
    
    async function listNFTForSale() {}
    
    return()
}