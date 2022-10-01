import { useState } from "react"
import { ethers } from 'ethers'
import { create as ipfsHttpClient } from 'ipfs-http-client'
import { useRouter } from 'next/router'
import Web3Modal from 'web3modal'

const client = ipfsHttpClient('https://ipfs.infura.io:5001/api/v0')

import SaigonMarketAddress from '../contractsData/SaigonMarket-address.json'
import SaigonMarketAbi from '../contractsData/SaigonMarket.json'
// Copy from '../artifacts/contracts/SaigonMarket.sol/SaigonMarket.json'
import SaigonNFTAddress from '../contractsData/SaigonNFT-address.json'
import SaigonNFTAbi from '../contractsData/SaigonNFT.json'
//Copied from '../artifacts/contracts/SaigonNFTFactory.sol/SaigonNFTFactory.json'

export default function CreateItem() {
    const[fileUrl, setFileUrl] = useState(null)
    const [formInput, updateFormInput] = useState({ price: '', name: '', description: ''})
    const router = useRouter()
    
    async function onChange(e) {
        e.preventDefault()
        /** Upload image to IPFS */
        const file = e.target.files[0]
        if (typeof file !== 'undefined') {
        try {
            const added = await client.add(
                file,
                {
                    progress: (prog) => console.log(`received: ${prog}`)
                }
            )
            const url = `https://ipfs.infura.io/ipfs/${added.path}`
            client.pin.add(added.path).then((res) => {
                console.log(res)
                setFileUrl(url)
            })
        } catch (error) {
            console.log('Error uploading file: ', error)
        }
    }
    }
    
    async function uploadToIPFS() {
        const { name, description, price } = formInput
        if (!name || !description || !price || !fileUrl) return
        /** First, upload metadata to IPFS */
        const data = JSON.stringify({ 
            name, description, price, image: fileUrl 
        })
        try {
            const added = await client.add(data)
            const url = `https://ipfs.infura.io/ipfs/${added.path}`
            /** after metadata is uploaded to IPFS, return the URL to use it in the transaction */
            return url
        } catch (error) {
            console.log('Error uploading file to ipfs: ', error)
        }
    }
    
    async function createListing() {
        const url = await uploadToIPFS()
        const web3Modal = new Web3Modal()
        const connection = await web3Modal.connect()
        const provider = new ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()
                
        /** Mint & List the NFT */
        let nft = new ethers.Contract(SaigonNFTAddress, SaigonNFTAbi.abi, signer)
        let market = new ethers.Contract(SaigonMarketAddress, SaigonMarketAbi.abi, signer)
        // mint nft
        console.log("Minting NFT...")
        let mintTx = await nft.mint(url)
        console.log(mintTx)
        const mintTxReceipt = await mintTx.wait()
        console.log(mintTxReceipt)
        // get tokenId of new nft
        const tokenId = mintTxReceipt.event[0].args.tokenId
        // approve marketplace to spend nft
        console.log("Approving NFT...")
        let approvalTx = await nft.setApprovalForAll(market.address, true)
        await approvalTx.wait()
        // add nft to marketplace
        console.log("Listing NFT...")
        const pricePerItem = ethers.utils.parseUnits(formInput.price, 'ether')
        let transaction = await market.createListing(nft.address, tokenId, pricePerItem)
        await transaction.wait()
        console.log("NFT Listed!")
        
        router.push('/') // promt the user to Home after creating the listing
    }
    
    return(
        <div className="flex justify-center">
            <div className="w-1/2 flex flex-col pb-12">
                <input 
                    placeholder="Asset Name"
                    className="mt-8 border rounded p-4"
                    onChange={e => updateFormInput({ ...formInput, name: e.target.ariaValueText })}
                />
                <textarea 
                    placeholder="Asset Description"
                    className="mt-2 border rounded p-4"
                    onChange={e => updateFormInput({ ...formInput, description: e.target.value })}
                />
                <input 
                    placeholder="Asset Price in ETH"
                    className="mt-2 border rounded p-4"
                    onChange={e => updateFormInput({ ...formInput, price: e.target.valueAsNumber })}
                />
                <input 
                    type="file"
                    name="Asset"
                    className="my-4"
                    onChange={onChange}
                />
                {
                    fileUrl && (
                        <img className="rounded mt-4" width="350" src="fiileUrl" />
                    )
                }
                <button onClick={createListing} className="font-bold mt-4 bg-pink-500 text-white rounded p-4 shadow-lg">
                    Create NFT
                </button>
            </div>
        </div>
    )
}