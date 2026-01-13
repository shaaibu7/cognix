// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CognixToken.sol";

/**
 * @title CognixTokenTest
 * @dev Test suite for CognixToken ERC20 implementation
 */
contract CognixTokenTest is Test {
    CognixToken public token;
    
    // Test accounts
    address public owner;
    address public alice;
    address public bob;
    address public charlie;
    
    // Test constants
    string constant TOKEN_NAME = "Cognix Token";
    string constant TOKEN_SYMBOL = "CGX";
    uint256 constant INITIAL_SUPPLY = 1000000 * 10**18; // 1 million tokens
    uint256 constant MAX_SUPPLY = 1000000000 * 10**18; // 1 billion tokens
    
    // Events for testing
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function setUp() public {
        // Set up test accounts
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        
        // Deploy token contract
        vm.prank(owner);
        token = new CognixToken(TOKEN_NAME, TOKEN_SYMBOL, INITIAL_SUPPLY, owner);
    }
    
    // Helper functions for testing
    
    function _mintTokens(address to, uint256 amount) internal {
        vm.prank(owner);
        token.mint(to, amount);
    }
    
    function _approveTokens(address from, address spender, uint256 amount) internal {
        vm.prank(from);
        token.approve(spender, amount);
    }
    
    function _transferTokens(address from, address to, uint256 amount) internal {
        vm.prank(from);
        token.transfer(to, amount);
    }
    
    function _transferFromTokens(address spender, address from, address to, uint256 amount) internal {
        vm.prank(spender);
        token.transferFrom(from, to, amount);
    }
    
    function _burnTokens(address from, uint256 amount) internal {
        vm.prank(from);
        token.burn(amount);
    }
    
    function _burnFromTokens(address spender, address from, uint256 amount) internal {
        vm.prank(spender);
        token.burnFrom(from, amount);
    }
    
    // Basic deployment and initialization tests
    
    function test_Deployment() public {
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.owner(), owner);
        assertTrue(token.hasOwner());
    }
    
    function test_InitialState() public {
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 0);
        assertEq(token.allowance(owner, alice), 0);
        assertEq(token.allowance(alice, bob), 0);
    }
}