const { ethers } = require("ethers");
const Collection = require('../artifacts/contracts/NFTcollection.sol/NFTcollection.json')
const Marketplace = require('../artifacts/contracts/Marketplace.sol/Marketplace.json')
require('dotenv').config({path: './process.env'});
const { PRIVATE_KEY, PUBLIC_KEY, GOERLI_URL, COLLECTION_CONTRACT_ADDRESS, MARKETPLACE_CONTRACT_ADDRESS, INFURA_API_KEY } = process.env;


//REMEMBER if Library is NOT deployed or needs redeployment on Goerli then DEPLOY and update .env accordingly with PRIVATE_KEY, PUBLIC_KEY, LIBRARY_CONTRACT_ADDRESS
const run = async function() {
    const provider = new ethers.providers.JsonRpcProvider(GOERLI_URL)

    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    const balance = await wallet.getBalance();
    console.log(ethers.utils.formatEther(balance, 18))

    const collectionContract = new ethers.Contract(COLLECTION_CONTRACT_ADDRESS, NFTcollection.abi, wallet)
    const marketplaceContract = new ethers.Contract(MARKETPLACE_CONTRACT_ADDRESS, Marketplace.abi, wallet)
}
    
run()