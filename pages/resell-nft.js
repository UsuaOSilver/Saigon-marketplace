import { ethers } from 'ethers'
import { useEffect, useState } from "react"
import { useRouter } from 'next/router'
import axios from 'axios'
import Web3Modal from 'web3modal'

import SaigonMarketAddress from '../contractsData/SaigonMarket-address.json'
import SaigonMarketAbi from '../contractsData/SaigonMarket.json'
// Copy from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'
import SaigonNFTAddress from '../contractsData/SaigonNFT-address.json'
import SaigonNFTAbi from '../contractsData/SaigonNFT.json'
//Copied from '../artifacts/contracts/SaigonNFTFactory.sol/SaigonNFTFactory.json'

export default function ResellNFT() {
    const [formInput, updateFormInput] = useState({ price: '', image: '' })
    const router = useRouter()
    const { id, tokenURI } = router.query
    const { image, name, description, price } = formInput
    
    useEffect(() => {
        fetchNFT()
    }, [id])
    
    async function fetchNFT() {
        if (!tokenURI) return
        const meta = await axios.get(tokenURI)
        updateFormInput(state => ({ ...state, image: meta.data.image }))
    }
    
    async function listNFTForSale() {
        if(!price) return
        const web3Modal = new Web3Modal()
        const connection = web3Modal.connect()
        const provider = new ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()
        
        const priceFormatted = ethers.utils.parseUnits(formInput.price, 'ether')
        let contract = new ethers.Contract(marketplaceAddress, SaigonMarket.abi, signer)
        let listingPrice = await contract.getPricePerItem()
        
        listingPrice = listingPrice.toString()
        let transaction = await contract.resellToken(id, priceFormatted, { value: listingPrice })
        await transaction.wait()
        
        router.push('/')
    }
    
    return (
        <div className='flex justify-center'>
            <div className='w-1/2 flex flex-col pb-12'>
                <input 
                    placeholder='Listing Price in ETH'
                    className='mt-2 border rounded p-4'
                    onChange={e => updateFormInput({ ...formInput, price: e.target.valueAsNumber })}
                />
                <input 
                    placeholder='Description'
                    className='mt-2 border rounded p-4'
                    onChange={e => updateFormInput({ ...formInput, price: e.target.description })}
                />
                <input 
                    placeholder='Listing Name'
                    className='mt-2 border rounded p-4'
                    onChange={e => updateFormInput({ ...formInput, price: e.target.ariaValueText })}
                />
                {
                    image && (
                        <img className='rounded mt-4' width='350' src={image} />
                    )
                }
                <button onClick={listNFTForSale} className='font-bold mt-4 bg-pink-500 text-white rounded p-4 shadow-lg'>
                    List NFT
                </button>
            </div>
        </div>
    )
}
