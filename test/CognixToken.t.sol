// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CognixToken.sol";

contract CognixTokenTest is Test {
    CognixToken public token;
    address public owner = address(0x1);
    address public user = address(0x2);
    
    function setUp() public {
        vm.prank(owner);
        token = new CognixToken("Cognix Token", "CGX", 1000000 * 1e18, owner);
    }
    
    function testInitialState() public {
        assertEq(token.name(), "Cognix Token");
        assertEq(token.symbol(), "CGX");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000000 * 1e18);
        assertEq(token.balanceOf(owner), 1000000 * 1e18);
        assertEq(token.owner(), owner);
    }
    
    function testMint() public {
        vm.prank(owner);
        token.mint(user, 1000 * 1e18);
        
        assertEq(token.balanceOf(user), 1000 * 1e18);
        assertEq(token.totalSupply(), 1001000 * 1e18);
    }
    
    function testBurn() public {
        vm.prank(owner);
        token.transfer(user, 1000 * 1e18);
        
        vm.prank(user);
        token.burn(500 * 1e18);
        
        assertEq(token.balanceOf(user), 500 * 1e18);
        assertEq(token.totalSupply(), 999500 * 1e18);
    }
    
    function testPause() public {
        vm.prank(owner);
        token.pause();
        
        assertTrue(token.paused());
        
        vm.expectRevert();
        vm.prank(owner);
        token.transfer(user, 100 * 1e18);
    }
    
    function testUnauthorizedMint() public {
        vm.expectRevert();
        vm.prank(user);
        token.mint(user, 1000 * 1e18);
    }
}