// Following is used for Production Release, uncomment when deployment
var WalletProvider = require("truffle-wallet-provider");
var keystore = require('fs').readFileSync('./keystore').toString();
var pass = require('fs').readFileSync('./pass').toString();
var wallet = require('ethereumjs-wallet').fromV3(keystore, pass, true);

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
        network_id: 3,
        provider: new WalletProvider(wallet, "http://45.76.197.72:8545")
    }
  }
};

