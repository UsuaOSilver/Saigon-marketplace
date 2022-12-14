
# Cho Saigon Market
_21st September 2022_

_ANH NGUYEN_

## OVERVIEW
An NFT marketplace that allows users to buy, sell, and create their own auction houses with the special Variable Rate GDA (VRGDA) price strategy. 

Payment is accepted with any ERC20 tokens depending on the auction house owner. ERC721 and ERC1155 token standards are supported. Royalties will be set by the creator of the NFT collection to honor creatives and artists.

## DELIVERABLES

### Web App: A user-friendly web application that allows users to:
1. Connect their wallets
2. Execute crypto-to-crypto transactions directly within the marketplace. Users can easily list NFTs in a stable value asset like USD and then purchase on-demand in another cryptocurrency using Chainlink for real-time exchange rates. Chainlink Price Feeds supports the following VND/USD, USDC/USD, DAI/USD, ETH/USDC, BTC/USDC, and ETH/BTC
3. Browse all the NFT collections on the platforms
4. Navigate to pages, explore information
    - Landing page (Design A): 
      - News & Events
      - Sales Information Ranking Board which includes volume, floor price of the top 20 NFT collections aggregated from other marketplaces
      - Featured collections
    - Selected collection page: display all NFT listings of that collection with the price (Design B)
    - Selected NFT listing page: 
      - Direct listing: price, owner wallet address, buy button.
      - If not on sale: bid prices, time bid, and addresses of all bidders.
    - Artist Information page (Design C)
    - Dashboard: user’s listed items (Design B)
    - My NFT: User’s owned NFT page. User can see their NFTs that are not on sale and start a sale or an auction (Design B)
    - Create NFT page: users can input the price and the royalties for the NFT they want to put on sale (Design D)
    - Resell NFT page: users can input the information for the NFT they want to put on sale
    - Create Auction House page: users can input the start price of the NFT, the price change rate for their collection and the number of items in the collection. A graph implementing VRGDA showing how price changes with the user inputs will be displayed to map out a clear plan going forward for the auction.  

### Smart Contracts
  
1. SaigonNftFactory
    - The `mint()` function allows user to mint the NFT and pay the NFT creator.

2. SaigonMarket
    - A mapping to keep track of every NFT listing. 
    - A mapping to keep track of every NFT offer. 
    - The `Listing` struct stores the information of the nft, the tokenId, the listingId, the seller address, the owner address, the price, and the sale status.
    - The `createNFTListing()` function allows users to input NFT data to mint a token and list it in the marketplace.
    - The `listNFT()` function creates the sale of a NFT, trasnfers the NFT ownership.
    - The `resellToken()` function allows anyone to resell a token they have purchased. 
    - The `createMarketSale()` function trigger a sale when the user purchases the listing.
    - The `fetchMarketListings()` function returns all unsold market items to display them on the landing page at the Feature section.
    - The `fetchMyNFTs()` function returns only the items that the user has purchased to display them on the My NFT page.
    - The `fetchOwnedListings()` function returns only item a user has listed to display them on the Dashboard page.

3. SaigonAuctionHouse 
    - `createAuction()` function creates a new auction for a given item
    - `placeBid()` function places a new bid, out bidding the existing bidder if found and criteria is reached
    - `withdrawBid()` function allows the hightest bidder to withdraw the bid (after 12 hours post auction's end)
    - `closeAuction()` function closes a finished auction and rewards the highest bidder
    - `cancelAuction()` function cancels and inflight and un-resulted auctions, returning the funds to the top bidder if found
    - `updateMinBidIncrement()` function updates the amount by which bids have to increase, across all auctions
    - `updateBidWithdrawalLockTime()` function updates the global bid withdrawal lockout time
    - `updateAuctionReservePrice()` function updates the current reserve price for an auction
    - `updateAuctionStartTime()` function updates the current start time for an auction
    - `updateAuctionStartTime()` function updates the current end time for an auction

------

## WORKFLOW VISUAL

![image](https://user-images.githubusercontent.com/48362877/190517243-f216dad0-0d01-4bca-9cba-76a5da69913e.png)
------

## FURTHER DEVELOPMENT
- Allow users to create a collection with customized name & symbol.


## DESIGNS

A.

B. 
![image](https://user-images.githubusercontent.com/48362877/190514990-9f3b2858-fe73-49b6-b970-c97c921c6a4f.png)

C.
![image](https://user-images.githubusercontent.com/48362877/190515013-ca0c9657-a0e8-441b-a62c-d2d24661c7f3.png)

D.

------

## LINKS:

[Variable Rate GDAs](https://www.paradigm.xyz/2022/08/vrgda)
