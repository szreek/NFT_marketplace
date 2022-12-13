import { HardhatUserConfig, subtask, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-etherscan";
require('dotenv').config({path: './process.env'});


const config: HardhatUserConfig = {
  solidity: "0.8.9",
};

const { GOERLI_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

task("deploy", "Deploys contract on a provided network")
    .setAction(async ({}) => {
         const deployMarketplace = require("./scripts/deploy");
          await deployMarketplace();
});

task("deploy-mainnet", "Deploys contract on a provided network")
    .addParam("privateKey", "Please provide the private key")
    .setAction(async ({privateKey}) => {
         const deployMarketplace = require("./scripts/deploy-mainnet");
          await deployMarketplace(privateKey);
});

subtask("print", "Prints a message")
    .addParam("message", "The message to print")
    .setAction(async (taskArgs) => {console.log(taskArgs.message);
});      

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
      },
      {
        version: "0.8.1",
      },
    ],
  },
};

module.exports = {
  defaultNetwork: "localhost",
  networks: {
    localhost: {
    },
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY]
    }
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at <https://etherscan.io/>
    apiKey: ETHERSCAN_API_KEY
  },

  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}

allowUnlimitedContractSize: true
export default config;
