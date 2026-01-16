// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Cognix Token - ERC20 Implementation
/// @notice A standard ERC20 token with transfer and approval functionality
contract CognixToken {
    string public name = "Cognix Token";
    string public symbol = "CGX";
    uint8 public constant decimals = 18;
    uint256 public immutable totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    /// @notice Emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice Emitted when an approval is granted
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /// @notice Creates a new Cognix Token
    /// @param _name Token name
    /// @param _symbol Token symbol
    /// @param _supply Initial token supply
    /// @param _owner Address to receive initial supply
    constructor(string memory _name, string memory _symbol, uint256 _supply, address _owner) {
        require(_owner != address(0), "Invalid owner address");
        name = _name;
        symbol = _symbol;
        totalSupply = _supply;
        balanceOf[_owner] = _supply;
        emit Transfer(address(0), _owner, _supply);
    }
    
    /// @notice Transfers tokens to a recipient
    /// @param to Recipient address
    /// @param amount Amount to transfer
    /// @return success True if transfer succeeded
    function transfer(address to, uint256 amount) external returns (bool success) {
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    /// @notice Approves spender to transfer tokens on behalf of caller
    /// @param spender Address authorized to spend
    /// @param amount Amount approved for spending
    /// @return success True if approval succeeded
    function approve(address spender, uint256 amount) external returns (bool success) {
        require(spender != address(0), "Invalid spender");
        
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    /// @notice Transfers tokens from one address to another using allowance
    /// @param from Address to transfer from
    /// @param to Address to transfer to
    /// @param amount Amount to transfer
    /// @return success True if transfer succeeded
    function transferFrom(address from, address to, uint256 amount) external returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
}
