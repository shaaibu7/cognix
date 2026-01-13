// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title CognixToken
 * @dev Implementation of the ERC20 Token Standard with additional features
 */
contract CognixToken {
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address private _owner;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error UnauthorizedAccess(address caller, address required);
    error InvalidAddress(address provided);
    error ZeroAmount();
    error MaxSupplyExceeded(uint256 currentSupply, uint256 maxSupply);
    
    uint256 public constant MAX_SUPPLY = 1000000000 * 10**18;
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address owner_
    ) {
        if (owner_ == address(0)) revert InvalidAddress(owner_);
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
    
    modifier onlyOwner() {
        if (msg.sender != _owner) revert UnauthorizedAccess(msg.sender, _owner);
        _;
    }
    
    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public pure returns (uint8) { return _decimals; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function allowance(address ownerAddr, address spender) public view returns (uint256) { return _allowances[ownerAddr][spender]; }
    function owner() public view returns (address) { return _owner; }
    function hasOwner() public view returns (bool) { return _owner != address(0); }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) revert InvalidAddress(from);
        if (to == address(0)) revert InvalidAddress(to);
        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) revert InsufficientBalance(fromBalance, amount);
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
    
    function _approve(address ownerAddr, address spender, uint256 amount) internal {
        if (ownerAddr == address(0)) revert InvalidAddress(ownerAddr);
        if (spender == address(0)) revert InvalidAddress(spender);
        _allowances[ownerAddr][spender] = amount;
        emit Approval(ownerAddr, spender, amount);
    }
    
    function _spendAllowance(address ownerAddr, address spender, uint256 amount) internal {
        uint256 currentAllowance = _allowances[ownerAddr][spender];
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) revert InsufficientAllowance(currentAllowance, amount);
            unchecked { _approve(ownerAddr, spender, currentAllowance - amount); }
        }
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress(newOwner);
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function renounceOwnership() public onlyOwner {
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }
    
    function mint(address to, uint256 amount) public onlyOwner {
        if (to == address(0)) revert InvalidAddress(to);
        uint256 newTotalSupply = _totalSupply + amount;
        if (newTotalSupply > MAX_SUPPLY) revert MaxSupplyExceeded(newTotalSupply, MAX_SUPPLY);
        _totalSupply = newTotalSupply;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    function burn(uint256 amount) public {
        uint256 accountBalance = _balances[msg.sender];
        if (accountBalance < amount) revert InsufficientBalance(accountBalance, amount);
        unchecked {
            _balances[msg.sender] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(msg.sender, address(0), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _spendAllowance(account, msg.sender, amount);
        uint256 accountBalance = _balances[account];
        if (accountBalance < amount) revert InsufficientBalance(accountBalance, amount);
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
    }
}