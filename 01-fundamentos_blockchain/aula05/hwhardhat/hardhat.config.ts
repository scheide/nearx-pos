/*
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
};

export default config;
*/

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

//import dotenv from "dotenv";
//dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  defaultNetwork: "local",
  networks: {

    local:{
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
      accounts:{
        mnemonic: "test test test test test test test test test test test junk"
      }
    },

    /*
    sepolia: {
      url: process.env.INFURA_URL,
      chainId: Number(process.env.CHAIN_ID),
      accounts: [String(process.env.PVK_ACCOUNT1)]      
    },
    //https://academy.binance.com/pt/articles/connecting-metamask-to-binance-smart-chain

    bsctest: {
      url: process.env.BSCTEST_URL,
      chainId: Number(process.env.BSC_CHAIN_ID),
      accounts: [String(process.env.PVK_ACCOUNT1)]      
    }
    */
  },
  etherscan: {
    //apiKey: process.env.API_KEY
    //apiKey: process.env.API_KEY_BSC
  },
  sourcify: {
    enabled: false
  }

};

export default config;
