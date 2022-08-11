require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config()

const { URL, KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.7",
  networks: {
    ropsten: {
      url: URL,
      accounts: [KEY]
    }
  }
};
