// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const {ethers} = require("hardhat");

async function main() {
  console.log('Deploying contract.....')
  const contractFactory = await ethers.getContractFactory('GashaponNFT')
  const deployedContract = await contractFactory.deploy()
  await deployedContract.deployed()
  let tx = deployedContract.deployTransaction
  let result = await tx.wait()
  if (!result.status) {
    console.log('Deploying contract TRANSACTION FAILED!!! ---------------')
    console.log('Transaction hash:' + tx.hash)
    throw (Error('failed to deploy contract'))
  }
  console.log('Contract deploy transaction hash:' + tx.hash)
  console.log('Contract deployed to:', deployedContract.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
