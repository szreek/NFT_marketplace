const { ethers } = require("ethers");
const Collection = require('../artifacts/contracts/Collection.sol/Collection.json')
const Marketplace = require('../artifacts/contracts/Marketplace.sol/Marketplace.json')
require('dotenv').config({path: './process.env'});
const { PRIVATE_KEY_LOCAL, COLLECTION_CONTRACT_ADDRESS_LOCAL, MARKETPLACE_CONTRACT_ADDRESS_LOCAL } = process.env;



//REMEMBER to start localhost node not hardhat node, and deploy the contract, then update COLLECTION_CONTRACT_ADDRESS and MARKETPLACE_CONTRACT_ADDRESS_LOCAL are in .env :)
const run = async function() {
    const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/")


    const wallet = new ethers.Wallet(PRIVATE_KEY_LOCAL, provider);
    const balance = await wallet.getBalance();
    console.log(ethers.utils.formatEther(balance, 18))

    const collectionContract = new ethers.Contract(COLLECTION_CONTRACT_ADDRESS_LOCAL, Collection.abi, wallet)
    const marketplaceContract = new ethers.Contract(MARKETPLACE_CONTRACT_ADDRESS_LOCAL, Marketplace.abi, wallet)

}
    
run()