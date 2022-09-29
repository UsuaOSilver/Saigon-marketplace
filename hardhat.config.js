require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
require("@nomiclabs/hardhat-etherscan");
require('hardhat-gas-reporter');
require('solidity-coverage');
require('@nomiclabs/hardhat-solhint');
require('hardhat-contract-sizer');
require('@openzeppelin/hardhat-upgrades');

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
    },
    goerli: {
        url: INFURA_GOERLI_RPC_URL,
        accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
        saveDeployments: true,
        chainId: 5,
    },
    polygon: {
        url: POLYGON_MAINNET_RPC_URL,
        accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
        saveDeployments: true,
        chainId: 137,
    },
    mumbai: {
        url: MUMBAI_RPC_URL,
        accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
        saveDeployments: true,
        chainId: 80001,
    },
  },
  etherscan: {
    // npx hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
    apiKey: {
        goerli: ETHERSCAN_API_KEY,
        polygon: POLYGONSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: REPORT_GAS,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    // coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
  contractSizer: {
    runOnCompile: false,
    only: ["SaigonMarket"],
  },
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
    },
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
}