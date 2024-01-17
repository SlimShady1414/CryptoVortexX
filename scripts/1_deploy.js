async function main() {
  console.log(`Preparing deployment...\n`)

  // Fetch contract factories
  const Token = await ethers.getContractFactory('Token')
  const Exchange = await ethers.getContractFactory('Exchange')

  // Fetch accounts
  const accounts = await ethers.getSigners()

  console.log(`Accounts fetched:\n${accounts[0].address}\n${accounts[1].address}\n`)

  // Deploy Token contracts
  const dapp = await Token.deploy('Slim Shady', 'SLIM', '1000000')
  await dapp.deployed()
  console.log(`SLIM Token Deployed to: ${dapp.address}`)

  const mETH = await Token.deploy('mETH', 'mETH', '1000000')
  await mETH.deployed()
  console.log(`mETH Token Deployed to: ${mETH.address}`)

  const mDAI = await Token.deploy('mDAI', 'mDAI', '1000000')
  await mDAI.deployed()
  console.log(`mDAI Token Deployed to: ${mDAI.address}`)

  // Deploy Exchange contract with a fee account and fee percent
  const exchange = await Exchange.deploy(accounts[1].address, 10)
  await exchange.deployed()
  console.log(`Exchange Contract Deployed to: ${exchange.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
