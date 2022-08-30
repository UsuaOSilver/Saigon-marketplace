const hre = require("hardhat");
const fs = require('fs');

async function main() {
  const SaigonMarket = await hre.ethers.getContractFactory("SaigonMarket");
  const saigonMarket = await SaigonMarket.deploy();
  await saigonMarket.deployed();
  console.log("saigonMarket deployed to:", saigonMarket.address);
  
  fs.writeFileSync('./config.js', `export const marketplaceAddress = "${saigonMarket.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
