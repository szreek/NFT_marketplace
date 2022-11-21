import { ethers } from "hardhat";
import hre from 'hardhat';

async function deployCollection() {
  await hre.run('compile');
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address); // We are printing the address of the deployer
  console.log('Account balance:', (await deployer.getBalance()).toString()); // We are printing the account balance

  const Collection = await ethers.getContractFactory("Collection");
  const collection = await Collection.deploy();
  await collection.deployed();

  console.log("Collection deployed to:", collection.address);
  await hre.run('print', { message: "Done!" })
}

async function deployMarketplace() {
  await hre.run('compile');
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address); // We are printing the address of the deployer
  console.log('Account balance:', (await deployer.getBalance()).toString()); // We are printing the account balance

  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();
  await marketplace.deployed();

  console.log("Collection deployed to:", marketplace.address);
  await hre.run('print', { message: "Done!" })
}

module.exports = deployCollection;
module.exports = deployMarketplace;
