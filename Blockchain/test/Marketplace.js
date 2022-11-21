const { expect } = require('chai');
const { ethers } = require('hardhat');
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe('Marketplace', () => {
  let marketplace

  async function deployMarketplaceFixture() {
        const [deployer, otherAccount] = await ethers.getSigners();
        const Marketplace = await ethers.getContractFactory('Marketplace')
        marketplace = await Marketplace.deploy()
        await marketplace.deployed();
        return { marketplace, deployer, otherAccount};
  }

  describe('Marketplace', () => {
    
    it('First Test for Marketplace', async () => {
      marketplace = await loadFixture(deployMarketplaceFixture);
      //expect
    })

  })

})