// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title CognixToken
 * @dev Implementation of the ERC20 Token Standard
 * @author Cognix Team
 */
contract CognixToken {
    // Token metadata
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;
    
    // Token state
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Access control
    address private _owner;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Custom errors for gas efficiency
    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error UnauthorizedAccess(address caller, address required);
    error InvalidAddress(address provided);
    
    /**
     * @dev Constructor that sets the token name, symbol, and initial supply
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param initialSupply_ The initial supply of tokens (in wei units)
     * @param owner_ The initial owner of the contract
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address owner_
    ) {
        if (owner_ == address(0)) {
            revert InvalidAddress(owner_);
        }
        
        _name = name_;
        _symbol = symbol_;
        _owner = owner_;
        
        if (initialSupply_ > 0) {
            _totalSupply = initialSupply_;
            _balances[owner_] = initialSupply_;
            emit Transfer(address(0), owner_, initialSupply_);
        }
        
        emit OwnershipTransferred(address(0), owner_);
    }
    
    /**
     * @dev Modifier to restrict access to owner only
     */
    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert UnauthorizedAccess(msg.sender, _owner);
        }
        _;
    }
    
    // View functions
    
    /**
     * @dev Returns the name of the token
     */
    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
     * @dev Returns the symbol of the token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    /**
     * @dev Returns the number of decimals used to get its user representation
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev Returns the amount of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev Returns the amount of tokens owned by account
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
     * @dev Returns the address of the current owner
     */
    function owner() public view returns (address) {
        return _owner;
    }
}
    // Core ERC20 functions
    
    /**
     * @dev Moves amount tokens from the caller's account to to
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return bool indicating success
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    
    /**
     * @dev Sets amount as the allowance of spender over the caller's tokens
     * @param spender The address which will spend the funds
     * @param amount The amount of tokens to be spent
     * @return bool indicating success
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    
    /**
     * @dev Moves amount tokens from from to to using the allowance mechanism
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return bool indicating success
     */
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    // Internal functions
    
    /**
     * @dev Moves amount of tokens from from to to
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     */
    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) {
            revert InvalidAddress(from);
        }
        if (to == address(0)) {
            revert InvalidAddress(to);
        }
        
        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) {
            revert InsufficientBalance(fromBalance, amount);
        }
        
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    /**
     * @dev Sets amount as the allowance of spender over the owner's tokens
     * @param owner The address which owns the funds
     * @param spender The address which will spend the funds
     * @param amount The amount of tokens to be spent
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) {
            revert InvalidAddress(owner);
        }
        if (spender == address(0)) {
            revert InvalidAddress(spender);
        }
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev Updates owner's allowance for spender based on spent amount
     * @param owner The address which owns the funds
     * @param spender The address which will spend the funds
     * @param amount The amount of tokens to be spent
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert InsufficientAllowance(currentAllowance, amount);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}