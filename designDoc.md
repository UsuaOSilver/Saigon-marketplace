
# Cho Saigon Market
_5th September 2022_

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

  1. SaigonMarket

  - A mapping to list to keep track of every NFT listing. The “MarketItem” struct to store tokenId, seller, owner, price, and sold status.
  - Creating a new charity with a goal, creator, token, beneficiary address, and deadline.
  - createToken function, which carries the createMarketItem function, allows users to mint a token and list it in the marketplace
  - resellToken function allows anyone to resell a token they have purchased. 
  - createMarketSale function creates the sale of a marketplace item by putting the item on sale, trasnferring ownership of the item, as well as funds between parties
  - fetchMarketItems function returns all unsold market items to display them on the landing page at the Feature section
  - fetchMyNFTs function returns only the items that the user has purchased to display them on the My NFT page
  - fetchItemsListed function returns only item a user has listed to display them on the Dashboard page

  2. AuctionHouse 

### WORKFLOW VISUAL:

![image](https://user-images.githubusercontent.com/48362877/188521043-19a3c95b-b29b-4dd9-85c2-d5e9fae37de9.png)


LINKS:
[Variable Rate GDAs](https://www.paradigm.xyz/2022/08/vrgda)
