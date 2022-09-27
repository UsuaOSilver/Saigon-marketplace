const { ethers } = require("ethers");
const { expect } = require ("chai");

const toWei = (num) => ethers.utils.parseEther(num.toString())
const fromWei = (num) => ethers.utils.formatEther(num)

describe("SaigonMarket", function() {
  let SaigonNFT, saigonNFT, SaigonMarket, saigonMarket,  deployer, addr1, addr2, addrs;
  let feeBps = 1;
  let URI = "Uri"; 
  
  beforeEach(async function () {
    /** Get ContractFactories and Signers */
    SaigonNFT = await ethers.getContractFactory("SaigonNFT");
    SaigonMarket = await ethers.getContractFactory("SaigonMarket");
    const [_, buyerAddress] = await ethers.getSigners()
    
    /** Deploy contracts */
    saigonNFT = await SaigonNFT.deploy();
    await saigonNFTS.deployed();
    saigonMarket = await SaigonMarket.deploy(feeBps);
    await saigonMarket.deployed();
  });
  
  describe("Deployment", function () {

    it("Should track name and symbol of the nft collection", async function () {
      // Expects the owner variable stored in the contract to be equal to Signer's owner.
      const nftName = "SaiGon Districts"
      const nftSymbol = "SGN"
      expect(await saigonNFT.name()).to.equal(nftName);
      expect(await saigonNFT.symbol()).to.equal(nftSymbol);
    });

    it("Should track feeReceiver and feeBps of the marketplace", async function () {
      expect(await saigonMarket.feeAccount()).to.equal(deployer.address);
      expect(await saigonMarket.feePercent()).to.equal(feeBps);
    });
  });
  
  it("Should create and execute market sales", async function() {
    
    
    
    
    
    
    let listingPrice = await saigonMarket.getListingPrice()
    listingPrice = listingPrice.toString()
    
    const auctionPrice = ethers.utils.parseUnits('1', 'ether')
    
    /** Create two tokens */
    await saigonMarket.createToken("https://www.mytokenlocation.com", auctionPrice, { value: listingPrice })
    await saigonMarket.createtoken("https://www.mytokenlocation.com", auctionPrice, { value: listingPrice })
    
    
    
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