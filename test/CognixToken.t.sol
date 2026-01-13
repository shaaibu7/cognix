// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CognixToken.sol";

contract CognixTokenTest is Test {
    CognixToken public token;
    address public owner = address(1);
    address public alice = address(2);
    address public bob = address(3);
    
    string constant TOKEN_NAME = "Cognix Token";
    string constant TOKEN_SYMBOL = "CGX";
    uint256 constant INITIAL_SUPPLY = 1000000 * 10**18;
    uint256 constant MAX_SUPPLY = 1000000000 * 10**18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function setUp() public {
        vm.prank(owner);
        token = new CognixToken(TOKEN_NAME, TOKEN_SYMBOL, INITIAL_SUPPLY, owner);
    }
    
    function test_Deployment() public {
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }
    
    function test_Transfer() public {
        uint256 amount = 1000 * 10**18;
        vm.prank(owner);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_TransferFrom() public {
        uint256 amount = 1000 * 10**18;
        vm.prank(owner);
        token.approve(alice, amount);
        
        vm.prank(alice);
        token.transferFrom(owner, bob, amount);
        
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.allowance(owner, alice), 0);
    }

    function test_Mint() public {
        uint256 amount = 500 * 10**18;
        vm.prank(owner);
        token.mint(alice, amount);
        assertEq(token.balanceOf(alice), amount);
    }

    function test_Burn() public {
        uint256 amount = 500 * 10**18;
        vm.prank(owner);
        token.burn(amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_UnauthorizedMint() public {
        vm.expectRevert();
        vm.prank(alice);
        token.mint(alice, 100);
    }
}