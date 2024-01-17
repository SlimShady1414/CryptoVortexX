// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;     // Address to receive trading fees
    uint256 public feePercent;     // Percentage of fee charged for trades
    mapping(address => mapping(address => uint256)) public tokens;  // User balances mapping
    mapping(uint256 => _Order) public orders;  // Existing orders mapping
    uint256 public orderCount;    // Counter to keep track of order IDs
    mapping(uint256 => bool) public orderCancelled;  // Mapping to check if an order is cancelled
    mapping(uint256 => bool) public orderFilled;     // Mapping to check if an order is filled

    // Events to log different actions on the exchange
    event Deposit(
        address token,
        address user,
        uint256 amount,
        uint256 balance
    );
    event Withdraw(
        address token,
        address user,
        uint256 amount,
        uint256 balance
    );
    event Order(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address creator,
        uint256 timestamp
    );

    struct _Order {
        uint256 id;           // Unique identifier for order
        address user;         // User who made the order
        address tokenGet;     // Token address user wants to receive
        uint256 amountGet;    // Amount user wants to receive
        address tokenGive;    // Token address user wants to give
        uint256 amountGive;   // Amount user wants to give
        uint256 timestamp;    // Order creation timestamp
    }

    // Constructor to initialize the fee account and percentage
    constructor(address _feeAccount, uint256 _feePercent) {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    // ------------------------
    // DEPOSIT & WITHDRAW TOKEN

    // Deposit tokens into the exchange
    function depositToken(address _token, uint256 _amount) public {
        // Transfer tokens from user to exchange
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));

        // Update user balance
        tokens[_token][msg.sender] += _amount;

        // Emit a Deposit event
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    // Withdraw tokens from the exchange
    function withdrawToken(address _token, uint256 _amount) public {
        // Ensure user has enough tokens to withdraw
        require(tokens[_token][msg.sender] >= _amount);

        // Transfer tokens from exchange to user
        Token(_token).transfer(msg.sender, _amount);

        // Update user balance
        tokens[_token][msg.sender] -= _amount;

        // Emit a Withdraw event
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    // Check the balance of a specific token for a user
    function balanceOf(address _token, address _user)
        public
        view
        returns (uint256)
    {
        return tokens[_token][_user];
    }

    // ------------------------
    // MAKE & CANCEL ORDERS

    // Make a new order on the exchange
    function makeOrder(
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive
    ) public {
        // Ensure the user has enough tokens to give
        require(balanceOf(_tokenGive, msg.sender) >= _amountGive);

        // Instantiate a new order
        orderCount ++;
        orders[orderCount] = _Order(
            orderCount,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            block.timestamp
        );

        // Emit an Order event
        emit Order(
            orderCount,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            block.timestamp
        );
    }

    // Cancel an existing order
    function cancelOrder(uint256 _id) public {
        // Fetch the order
        _Order storage _order = orders[_id];

        // Ensure the caller is the owner of the order
        require(address(_order.user) == msg.sender);

        // Ensure the order exists
        require(_order.id == _id);

        // Mark the order as cancelled
        orderCancelled[_id] = true;

        // Emit a Cancel event
        emit Cancel(
            _order.id,
            msg.sender,
            _order.tokenGet,
            _order.amountGet,
            _order.tokenGive,
            _order.amountGive,
            block.timestamp
        );
    }

    // ------------------------
    // EXECUTING ORDERS

    // Fill an order on the exchange
    function fillOrder(uint256 _id) public {
        // Check if it's a valid order ID
        require(_id > 0 && _id <= orderCount, "Order does not exist");
        // Check if the order is not filled
        require(!orderFilled[_id]);
        // Check if the order is not cancelled
        require(!orderCancelled[_id]);

        // Fetch the order
        _Order storage _order = orders[_id];

        // Execute the trade
        _trade(
            _order.id,
            _order.user,
            _order.tokenGet,
            _order.amountGet,
            _order.tokenGive,
            _order.amountGive
        );

        // Mark the order as filled
        orderFilled[_order.id] = true;
    }

    // Execute a trade between two users
    function _trade(
        uint256 _orderId,
        address _user,
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive
    ) internal {
        // Calculate the fee amount
        uint256 _feeAmount = (_amountGet * feePercent) / 100;  // Calculate fee amount (feePercent% of _amountGet)

        // Execute the trade
        tokens[_tokenGet][msg.sender] -= (_amountGet + _feeAmount);  // Deduct filled amount and fee from buyer's balance
        tokens[_tokenGet][_user] += _amountGet;  // Add filled amount to seller's balance
        tokens[_tokenGet][feeAccount] += _feeAmount;  // Add fee to fee account

        tokens[_tokenGive][_user] -= _amountGive;  // Deduct given amount from seller's balance
        tokens[_tokenGive][msg.sender] += _amountGive;  // Add given amount to buyer's balance

        // Emit a Trade event
        emit Trade(
            _orderId,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            _user,
            block.timestamp
        );
    }
}
