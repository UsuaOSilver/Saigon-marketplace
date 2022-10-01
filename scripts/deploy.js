const hre = require("hardhat");
const fs = require('fs');
const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

async function main() {
  const SaigonNFT = await hre.ethers.getContractFactory("SaigonNFT");
  const SaigonMarket = await hre.ethers.getContractFactory("SaigonMarket");
  const PriceSaigonMarket = await hre.ethers.getContractFactory("PriceSaigonMarket")
  
  const saigonNFT = await SaigonNFT.deploy();
  const saigonMarket = await SaigonMarket.deploy(1); // The marketplace fee is 1%
  const priceSaigonMarket = await PriceSaigonMarket.deploy();
  
  await saigonNFT.deployed();
  console.log("saigonNFT deployed to:", saigonNFT.address);
  await saigonMarket.deployed();
  console.log("saigonMarket deployed to:", saigonMarket.address);
  await priceSaigonMarket.deployed();
  console.log("priceSaigonMarket deployed to:", priceSaigonMarket.address);
  
  
  savedFrontendFiles(saigonNFT, "SaigonNFT");
  savedFrontendFiles(saigonMarket, "SaigonMarket");
  savedFrontendFiles(priceSaigonMarket, "PriceSaigonMarket");
  
  // Verify the deployment
  // if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
  //   console.log("Verifying...")
  //   await verify(saigonMarket.address, arguments)
  // }
}

function savedFrontendFiles(contract, name) {
  const contractsDir = "./contractsData";
  
  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }
  
  fs.writeFileSync(
    contractsDir + `/${name}-address.json`,
    JSON.stringify({ address: contract.address }, undefined, 2)
  );
  
  const contractArtifact = artifacts.readArtifactSync(name);
  
  fs.writeFileSync(
    contractsDir + `/${name}.json`,
    JSON.stringify(contractArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
