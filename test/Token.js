const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), 'ether')
}

describe('Token', () => {
  let token
  let accounts
  let deployer
  let receiver
  beforeEach(async () => {
    const Token = await ethers.getContractFactory('Token')
    token = await Token.deploy('Dapp University', 'DAPP',  '1000000')

    accounts = await ethers.getSigners() //returns array of all accounts
    deployer = accounts[0]
    receiver = accounts[1]
  })

  describe('Deployment', () => {
    const name = 'Dapp University'
    const symbol = 'DAPP'
    const decimals = '18'
    const totalSupply = tokens('1000000')

    it('has correct name', async () => {
      expect(await token.name()).to.equal(name)
    })

    it('has correct symbol', async () => {
      expect(await token.symbol()).to.equal(symbol)
    })

    it('has correct decimals', async () => {
      expect(await token.decimals()).to.equal(decimals)
    })

    it('has correct total supply', async () => {
      expect(await token.totalSupply()).to.equal(totalSupply)
    })

    it('assigns total supply to developer', async () => {
      expect(await token.balanceOf(deployer.address)).to.equal(totalSupply)
    })


  })

  describe('Sending Token', () => {
    let amount
    it('Transfers token balances', async () => {

      console.log("deployer balance before transfer", await token.balanceOf(deployer.address))
      console.log("receiver balance before transfer", await token.balanceOf(receiver.address))
      amount=tokens(100)

      let transaction = await token.connect(deployer).transfer(receiver.address, amount)
      let result = transaction.wait()
      //ensure that tokens were transfered

      console.log("deployer balance after transfer", await token.balanceOf(deployer.address))
      console.log("receiver balance after transfer", await token.balanceOf(receiver.address))
    })
  })

})
