import  Web3Provider from '../components/Web3Provider'
import { ExConnectWalletButton } from '../components/ExConnectWalletButton'
import ThemeSwitcher from '../components/ThemeSwitcher'
import '../styles/globals.css'
import Link from 'next/link'

function MyApp({ Component, pageProps }) {
  return (
    <Web3Provider>
      <div>
        <nav className="border-b p-6">
          <p className='text-4xl font-bold'>Saigon Market</p>
          <div className='flex mt-6'>
            <div className='flex mt-2'>
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
            <div className="flex justify-end flex-1 px-2">
              <div className="flex mr-6 items-stretch space-x-1">
                <ExConnectWalletButton />
                <ThemeSwitcher />
              </div>
            </div>
          </div>
        </nav>
        <Component {...pageProps} />
      </div>
    </Web3Provider>
  )
}

export default MyApp
