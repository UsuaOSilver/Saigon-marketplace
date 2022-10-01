const hre = require("hardhat");
const { expect } = require ("chai");

const toWei = (num) => ethers.utils.parseEther(num.toString())
const fromWei = (num) => ethers.utils.formatEther(num)

describe("SaigonMarket Unit Tests", function() {
  let SaigonNFT, saigonNFT, SaigonMarket, saigonMarket, PriceSaigonMarket, priceSaigonMarket, deployer, addr1, addr2, addr3;
  let feeBps = 1;
  let URI_1 = "https://www.token-abc-location.com"; 
  let URI_2 = "https://www.token-cba-location.com"; 
  
  beforeEach(async function () {
    /** Get ContractFactories and Signers */
    SaigonNFT = await hre.ethers.getContractFactory("SaigonNFT");
    SaigonMarket = await hre.ethers.getContractFactory("SaigonMarket");
    PriceSaigonMarket = await hre.ethers.getContractFactory("PriceSaigonMarket");

    [deployer, addr1, addr2, addr3] = await ethers.getSigners();
    
    /** Deploy contracts */
    saigonNFT = await SaigonNFT.deploy();
    await saigonNFT.deployed();
    saigonMarket = await SaigonMarket.deploy(feeBps);
    await saigonMarket.deployed();
    priceSaigonMarket = await PriceSaigonMarket.deploy();
    await priceSaigonMarket.deployed();
  });
  
  describe("Deployment", function () {

    it("Should track name and symbol of the nft collection", async function () {
      // Expects the owner variable stored in the contract to be equal to Signer's owner.
      const nftName = "SaiGon Districts"
      const nftSymbol = "SGN"
      expect(await saigonNFT.name()).to.equal(nftName);
      expect(await saigonNFT.symbol()).to.equal(nftSymbol);
    });

    it("Should track the operator and feeBps of the marketplace", async function () {
      expect(await saigonMarket.operator()).to.equal(deployer.address);
      expect(await saigonMarket.feeBps()).to.equal(feeBps);
    });
  })
  
  describe("mint", function () {

    it("Should track each minted NFT", async function () {
      // addr1 mints an nft
      await saigonNFT.connect(addr1).mint(URI_1)
      expect(await saigonNFT._tokenIds()).to.equal(1);
      expect(await saigonNFT.balanceOf(addr1.address)).to.equal(1);
      expect(await saigonNFT.tokenURI(1)).to.equal(URI_1);
      // addr2 mints an nft
      await saigonNFT.connect(addr2).mint(URI_2)
      expect(await saigonNFT._tokenIds()).to.equal(2);
      expect(await saigonNFT.balanceOf(addr2.address)).to.equal(1);
      expect(await saigonNFT.tokenURI(2)).to.equal(URI_2);
    });
  })
  
  describe("createListing", function () {
    let price = toWei(1)
    beforeEach(async function () {
      // addr1 mints an nft
      await saigonNFT.connect(addr1).mint(URI_1)
      // addr1 approves marketplace to spend nft
      await saigonNFT.connect(addr1).setApprovalForAll(saigonMarket.address, true)
    })
    it("Should track newly created listing, transfer NFT from seller to marketplace and emit NFTListed event", async function () {
      // addr1 offers their nft at a price of 1 ether
      await expect(saigonMarket.connect(addr1).createListing(saigonNFT.address, 1, price))
        .to.emit(saigonMarket, "NFTListed")
        .withArgs(
          // 1,
          saigonNFT.address,
          1,
          addr1.address,
          saigonMarket.address,
          price,
          false
        )
      // Owner of NFT should now be the marketplace
      expect(await saigonNFT.ownerOf(1)).to.equal(saigonMarket.address);
      // listing count should now equal 1
      expect(await saigonMarket._listingIds()).to.equal(1)
      // Get listing from listings mapping then check fields to ensure they are correct
      const listing = await saigonMarket.listings(saigonNFT.address, 1)
      expect(listing.listingId).to.equal(1)
      expect(listing.nft).to.equal(saigonNFT.address)
      expect(listing.tokenId).to.equal(1)
      expect(listing.pricePerItem).to.equal(price)
      expect(listing.sold).to.equal(false)
    });
    it("Should fail if price is set to zero", async function () {
      await expect(
        saigonMarket.connect(addr1).createListing(saigonNFT.address, 1, 0)
      ).to.be.revertedWith("PriceMustBeAboveZero");
    });
  })
  
  describe("createMarketSale", function () {
    let price = toWei(2)
    let fee = (feeBps/100)*price
    let totalPriceInWei
    beforeEach(async function () {
      // addr1 mints an nft
      await saigonNFT.connect(addr1).mint(URI_1)
      // addr1 approves marketplace to spend tokens
      await saigonNFT.connect(addr1).setApprovalForAll(saigonMarket.address, true)
      // addr1 makes their nft a marketplace listing.
      await saigonMarket.connect(addr1).createListing(saigonNFT.address, 1 , price)
    });
    it("Should update listing as sold, pay seller, transfer NFT to buyer, charge fees and emit a ListingSold event", async function () {
      const sellerInitalEthBal = await addr1.getBalance()
      const operatorInitialEthBal = await deployer.getBalance()
      // fetch listings total price (market fees + nft price)
      totalPriceInWei = await saigonMarket.getFinalPrice(saigonNFT.address, 1);
      // addr 2 purchases listing.
      await expect(saigonMarket.connect(addr2).createMarketSale(saigonNFT.address, 1, {value: totalPriceInWei}))
      .to.emit(saigonMarket, "ListingPurchased")
        .withArgs(
          addr1.address,
          addr2.address,
          1,
          // 1,
          price,
          true
        )
      const sellerFinalEthBal = await addr1.getBalance()
      const operatorFinalEthBal = await deployer.getBalance()
      // listing should be marked as sold
      expect((await saigonMarket.listings(saigonNFT.address, 1)).sold).to.equal(true)
      // Seller should receive payment for the price of the NFT sold.
      expect(+fromWei(sellerFinalEthBal)).to.equal(+price + +fromWei(sellerInitalEthBal))
      // operator should receive fee
      expect(+fromWei(operatorFinalEthBal)).to.equal(+fee + +fromWei(operatorInitialEthBal))
      // The buyer should now own the nft
      expect(await saigonNFT.ownerOf(1)).to.equal(addr2.address);
    });
    it("Should fail for invalid listing ids, sold listing and when not enough ether is paid", async function () {
      // fails for invalid listing ids
      await expect(
        saigonMarket.connect(addr2).createMarketSale(2, {value: totalPriceInWei})
      ).to.be.revertedWith("ListingNotExist");
      await expect(
        saigonMarket.connect(addr2).createMarketSale(0, {value: totalPriceInWei})
      ).to.be.revertedWith("ListingNotExist");
      // Fails when not enough ether is paid with the transaction. 
      // In this instance, fails when buyer only sends enough ether to cover the price of the nft
      // not the additional market fee.
      await expect(
        saigonMarket.connect(addr2).createMarketSale(1, {value: price})
      ).to.be.revertedWith("PriceNotMet"); 
      // addr2 purchases listing 1
      await saigonMarket.connect(addr2).createMarketSale(1, {value: totalPriceInWei})
      // addr3 tries purchasing listing 1 after its been sold 
      await expect(
        saigonMarket.connect(addr3).createMarketSale(1, {value: totalPriceInWei})
      ).to.be.revertedWith("ListingSold");
    });
  })
  
  describe("resellNFT", async function() {
    let price = toWei(2)
    let newPrice = toWei(1)
    beforeEach(async function () {
      // addr1 mints 2 nfts
      await saigonNFT.connect(addr1).mint(URI_1)
      await saigonNFT.connect(addr1).mint(URI_2)
      // addr1 approves marketplace to spend tokens
      await saigonNFT.connect(addr1).setApprovalForAll(saigonMarket.address, true)
      // addr1 makes their nfts marketplace listings.
      await saigonMarket.connect(addr1).createListing(saigonNFT.address, 1 , price)
      await saigonMarket.connect(addr1).createListing(saigonNFT.address, 2 , price)
      let totalPriceInWei = await saigonMarket.getFinalPrice(saigonNFT.address, 1);
      // addr 2 purchases listing.
      await saigonMarket.connect(addr2).createMarketSale(saigonNFT.address, 1, {value: totalPriceInWei})
    });
    it("Should update activated listing for resell", async function () {
      // addr2 offers their nft at a price of 2 ether
      await expect(saigonMarket.connect(addr2).resellNFT(saigonNFT.address, 1 , newPrice))
        .to.emit(saigonMarket, "NFTListedForResell")
        .withArgs(
          // 1,
          saigonNFT.address,
          1,
          addr2.address,
          saigonMarket.address,
          newPrice,
          false
        )
        // Owner of NFT should now be the marketplace
        expect(await saigonNFT.ownerOf(1)).to.equal(saigonMarket.address);
        // listing count should still equal 2
        expect(await saigonMarket._listingIds()).to.equal(2)
        // Get listing from listings mapping then check fields to ensure they are correct
        const listing = await saigonMarket.listings(saigonNFT.address, 1)
        expect(listing.listingId).to.equal(1)
        expect(listing.nft).to.equal(saigonNFT.address)
        expect(listing.tokenId).to.equal(1)
        expect(listing.pricePerItem).to.equal(newPrice)
        expect(listing.sold).to.equal(false)
    });
    it("Shoulf fail if the nft reseller is not the owner", async function () {
      // addr2 tries reselling listing 1 after its been sold to addr1
      await expect(
        saigonMarket.connect(addr2).resellNFT(saigonNFT.address, 1, {value: newPrice})
      ).to.be.revertedWith("NotOwner");
    });
  })
})