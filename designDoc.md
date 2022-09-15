
# Cho Saigon Market
_14th September 2022_

_Anh Nguyen_

## OVERVIEW
An NFT marketplace allowing users to create their own auction houses with Variable Rate GDA (VRGDA)1. Payment is accepted with any ERC20 tokens depending on the auction house owner. Other essential features of an NFT marketplace include buying, selling, making offers, and bidding. ERC721 and ERC1155 token standards are supported. Royalties will be set by the creator of the NFT collection to honor creatives and artists.

## DELIVERABLES

### Web App: A user-friendly web application that allows users to:
  1. Connect their wallets
  2. Browse all the NFT collections on the platforms
  3. Navigate to pages, explore information
  - The upper section displays the exchange rates of VND/USD, USDC/USD, ETH/USDC, BTC/USDC, and ETH/BTC fetched from Chainlink oracle
  - Landing page: News & Events, Sales Information including volume, floor price of the top 20 NFT collections aggregated from other marketplaces, and Featured collections.
  - Selected collection page: display all NFT listings of that collection with the Sales information
  - NFT listing page: 
    - Direct listing: price, owner wallet address, buy button.
    - If not on sale: bid prices, time bid, and addresses of all bidders.
  - Artist Information page
  - Dashboard: user’s listed items
  - My NFT: User’s owned NFT page
  - Create NFT page: users can input the price and the royalties for the NFT they want to put on sale
  - Resell NFT page: users can input the price of the NFT they want to put on sale
  - Create Auction House page: users can input the start price of the NFT, the price change rate for their collection and the number of items in the collection. A graph implementing VRGDA showing how price changes with the user inputs will be displayed to map out a clear plan of the auction perspective.  

### Smart Contracts: 
  
  1. NftFactory
  - The `mint()` function allows user to mint a token and create a listing


  2. SaigonMarket

  - A mapping to keep track of every NFT listing. 
  - The `MarketItem` struct to store tokenId, seller, owner, price, and sold status.
  - The `createToken` function, which carries the createMarketItem function, allows users to mint a token and list it in the marketplace.
  - The `resellToken` function allows anyone to resell a token they have purchased. 
  - The `createMarketSale` function creates the sale of a marketplace item by putting the item on sale, trasnferring ownership of the item, as well as funds between parties.
  - The `fetchMarketItems` function returns all unsold market items to display them on the landing page at the Feature section.
  - The `fetchMyNFTs` function returns only the items that the user has purchased to display them on the My NFT page.
  - The `fetchItemsListed` function returns only item a user has listed to display them on the Dashboard page.

  3. AuctionHouse 
------

## WORKFLOW VISUAL:

![image](https://user-images.githubusercontent.com/48362877/190517243-f216dad0-0d01-4bca-9cba-76a5da69913e.png)
------

## DESIGNS

A. 
![image](https://user-images.githubusercontent.com/48362877/190514990-9f3b2858-fe73-49b6-b970-c97c921c6a4f.png)

B.
![image](https://user-images.githubusercontent.com/48362877/190515013-ca0c9657-a0e8-441b-a62c-d2d24661c7f3.png)
------

## LINKS:

[Variable Rate GDAs](https://www.paradigm.xyz/2022/08/vrgda)
