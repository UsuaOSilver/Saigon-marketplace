const { ethers } = require("ethers")

describe("SaigonMarket", function() {
  it("Should create and execute market sales", async function() {
    
    /** Deploy the marketplace */
    const SaigonMarket = await ethers.getContractFactory("SaigonMarket")
    const saigonMarket = await SaigonMarket.deploy()
    await saigonMarket.deployed()
    
    let listingPrice = await saigonMarket.getListingPrice()
    listingPrice = listingPrice.toString()
    
    const auctionPrice = ethers.utils.parseUnits('1', 'ether')
    
    /** Create two tokens */
    await saigonMarket.createToken("https://www.mytokenlocation.com", auctionPrice, { value: listingPrice })
    await saigonMarket.createtoken("https://www.mytokenlocation.com", auctionPrice, { value: listingPrice })
    
    const [_, buyerAddress] = await ethers.getSigners()
    
    /** Execute sale of token to another user */
    await saigonMarket.connect(buyerAddress).createMarketSale(1, {value: auctionPrice })
    
    /** Resell a token */
    await saigonMarket.connect(buyerAddress).resellToken(1, auctionPrice, { value: listingPrice })
    
    /** Query for and return the unsold items */
    items = await saigonMarket.fetchMarketItem()
    items = await Promise.all(items.map(async i => {
      const tokenUri = await saigonMarket.tokenUri(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
    }))
    console.log('items: ', items)
  })
})