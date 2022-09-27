const hre = require("hardhat");
const fs = require('fs');

async function main() {
  const SaigonNFT = await hre.ethers.getContractFactory("SaigonNFT");
  const SaigonMarket = await hre.ethers.getContractFactory("SaigonMarket");
  const price = await hre.ethers.getContractFactory("PriceConsumerV3")
  
  const saigonNFT = await SaigonNFT.deploy();
  const saigonMarket = await SaigonMarket.deploy(1); // The marketplace fee is 1%
  
  await saigonNFT.deployed();
  console.log("saigonNFT deployed to:", saigonNFT.address);
  await saigonMarket.deployed();
  console.log("saigonMarket deployed to:", saigonMarket.address);
  
  
  savedFrontendFiles(saigonNFT, "SaigonNFT");
  savedFrontendFiles(saigonMarket, "SaigonMarket");
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
