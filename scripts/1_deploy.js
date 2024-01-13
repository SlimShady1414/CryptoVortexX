async function main() {
  const Token = await ethers.getContractFactory("Token") //ether is a library, gCF gets info from artifact folders to use smart contracts in blockchain

  //deploying the contracct
  const token = await Token.deploy()
  await token.deployed()
  console.log(`Token Deployed to: ${token.address}`)

}

main()
  .then(() => process.exit(0))
  .catch((error) =>{
    console.error(error);
    process.exit(1);
  });

