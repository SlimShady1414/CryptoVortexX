// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
    // Token details
    string public name;
    string public symbol;
    uint256 public decimals = 18;  // Number of decimal places
    uint256 public totalSupply;  // Total supply of tokens

    // User balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events to log transfer and approval actions
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // Constructor to initialize token details and allocate initial supply to the creator
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply * (10**decimals);  // Convert total supply to base units
        balanceOf[msg.sender] = totalSupply;  // Allocate total supply to the creator's balance
    }

    // Transfer tokens to a specified address
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);  // Check if the sender has enough balance

        _transfer(msg.sender, _to, _value);  // Execute the transfer

        return true;
    }

    // Internal function to execute the token transfer
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0));  // Ensure the destination address is valid

        balanceOf[_from] -= _value;  // Deduct tokens from the sender
        balanceOf[_to] += _value;  // Add tokens to the receiver

        // Emit Transfer event
        emit Transfer(_from, _to, _value);
    }

    // Approve spending of tokens by another address
    function approve(address _spender, uint256 _value)
        public
        returns(bool success)
    {
        require(_spender != address(0));  // Ensure the spender's address is valid

        allowance[msg.sender][_spender] = _value;  // Set allowance for the spender

        // Emit Approval event
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens from one address to another using allowance
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success)
    {
        require(_value <= balanceOf[_from]);  // Check if the sender has enough balance
        require(_value <= allowance[_from][msg.sender]);  // Check if the allowance is sufficient

        allowance[_from][msg.sender] -= _value;  // Deduct allowance from the spender

        _transfer(_from, _to, _value);  // Execute the transfer

        return true;
    }
}
