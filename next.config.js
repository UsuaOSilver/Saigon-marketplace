/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  env: {
    PRIVATE_KEY: process.env.PRIVATE_KEY,
    INFURA_IPFS_PROJECT_ID: process.env.INFURA_IPFS_PROJECT_ID,
    INFURA_IPFS_PROJECT_SECRET: process.env.INFURA_IPFS_PROJECT_SECRET,
    GOERLI_RPC_URL: process.env.GOERLI_RPC_URL,
    MUMBAI_RPC_URL: process.env.MUMBAI_RPC_URL,
    POLYGON_MAINNET_RPC_URL: process.env.POLYGON_MAINNET_RPC_URL,
    ETHERSCAN_API_KEY: process.env.ETHERSCAN_API_KEY, 
    REPORT_GAS: process.env.REPORT_GAS
  },
}

module.exports = nextConfig
