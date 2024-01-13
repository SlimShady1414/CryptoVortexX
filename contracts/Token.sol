//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
	//storing infos
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public totalSupply;

    //track balances
    mapping(address => uint256) public balanceOf; //mapping is a data structure(key-value pair)
    //send tokens

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply * (10**decimals);
        balanceOf[msg.sender] = totalSupply; //msg.sender is an address


    }
    function transfer(address _to, uint256 _value) public returns (bool success){
    	//deduct tokens from sender and credit tokens to receiver
    	balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
    	balanceOf[_to] = balanceOf[_to] + _value;
    }
}
