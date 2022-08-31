import '../styles/globals.css'
import Link from 'next/link'

import { WagmiConfig, createClient } from "wagmi";
import { ConnectKitProvider, ConnectKitButton, getDefaultClient } from "connectkit";

const alchemyId = process.env.ALCHEMY_ID;

const client = createClient(
  getDefaultClient({
    appName: "Your App Name",
    alchemyId,
  }),
);

function MyApp({ Component, pageProps }) {
  return (
    <WagmiConfig client={client}>
      <ConnectKitProvider theme="default" mode="dark">
        <div>
          <nav className="border-b p-6">
            <p className='text-4xl font-bold'>Saigon Market</p>
            <div className='flex mt-4'>
              <Link href="/">
                <a className='mr-4 text-pink-500'>Home</a>
              </Link>
              <Link href="/create-nft">
                <a className='mr-6 text-pink-500'>Sell NFT</a>
              </Link>
              <Link href="/my-nfts">
                <a className='mr-6 text-pink-500'>My NFTs</a>
              </Link>
              <Link href="/dashboard">
                <a className='mr-6 text-pink-500'>Dashboard</a>
              </Link>
            </div>
          </nav>
          <Component {...pageProps} />
        </div>
        <ConnectKitButton />
      </ConnectKitProvider>
    </WagmiConfig>
  )
}

export default MyApp
