require('dotenv').config();
const { Web3 } = require('web3');

const rpcUrl = process.env.RPC_URL;
const web3 = new Web3(rpcUrl);

async function main() {
  const address = '0x081296833CE9b1503Ac7918F3CC0CB9c335E1217';

  // Nouvelle syntaxe : Promise
  const balanceWei = await web3.eth.getBalance(address);
  const balanceEth = web3.utils.fromWei(balanceWei, 'ether');

  console.log(`Balance de ${address}: ${balanceEth} ETH`);
}

main().catch(console.error);