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
    
    async function onChange(e){
        /** Upload image to IPFS */
        const file = e.target.files[0]
        try {
            const added = await client.add(
                file,
                {
                    progress: (prog) => console.log(`received: ${prog}`)
                }
            )
            const url = `https://ipfs.infura.io/ipfs/${added.path}`
            setFileUrl(url)
        } catch (error) {
            console.log('Error uploading file: ', error)
        }
    }
    
    async function uploadToIPFS() {}
    
    async function listNFTForSale() {}
    
    return()
}