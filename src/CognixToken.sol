// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CognixToken is ERC20, Ownable, Pausable {
    uint8 private _decimals;
    
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _supply, 
        address _owner
    ) ERC20(_name, _symbol) Ownable(_owner) {
        _decimals = 18;
        _mint(_owner, _supply);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be > 0");
        _mint(to, amount);
        emit Mint(to, amount);
    }
    
    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    function _update(address from, address to, uint256 value) internal virtual override whenNotPaused {
        super._update(from, to, value);
    }
}
