// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CognixToken.sol";

/**
 * @title GasOptimizationTest
 * @dev Gas usage benchmarks for CognixToken operations
 */
contract GasOptimizationTest is Test {
    CognixToken public token;
    
    address public owner;
    address public alice;
    address public bob;
    
    uint256 constant INITIAL_SUPPLY = 1000000 * 10**18;
    
    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        
        vm.prank(owner);
        token = new CognixToken("Cognix Token", "CGX", INITIAL_SUPPLY, owner);
        
        // Give alice some tokens for testing
        vm.prank(owner);
        token.transfer(alice, 100000 * 10**18);
    }
    
    function test_GasUsage_Transfer() public {
        uint256 amount = 1000 * 10**18;
        
        vm.prank(alice);
        uint256 gasBefore = gasleft();
        token.transfer(bob, amount);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Transfer gas used:", gasUsed);
        // Should be around 51,000-55,000 gas
        assertLt(gasUsed, 60000, "Transfer should use less than 60k gas");
    }
    
    function test_GasUsage_Approve() public {
        uint256 amount = 5000 * 10**18;
        
        vm.prank(alice);
        uint256 gasBefore = gasleft();
        token.approve(bob, amount);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Approve gas used:", gasUsed);
        // Should be around 46,000-50,000 gas
        assertLt(gasUsed, 55000, "Approve should use less than 55k gas");
    }
    
    function test_GasUsage_TransferFrom() public {
        uint256 amount = 2000 * 10**18;
        
        // Setup allowance
        vm.prank(alice);
        token.approve(bob, amount);
        
        vm.prank(bob);
        uint256 gasBefore = gasleft();
        token.transferFrom(alice, owner, amount);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("TransferFrom gas used:", gasUsed);
        // Should be around 55,000-65,000 gas
        assertLt(gasUsed, 70000, "TransferFrom should use less than 70k gas");
    }
    
    function test_GasUsage_Mint() public {
        uint256 amount = 10000 * 10**18;
        
        vm.prank(owner);
        uint256 gasBefore = gasleft();
        token.mint(alice, amount);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Mint gas used:", gasUsed);
        // Should be around 51,000-55,000 gas
        assertLt(gasUsed, 60000, "Mint should use less than 60k gas");
    }
    
    function test_GasUsage_Burn() public {
        uint256 amount = 1000 * 10**18;
        
        vm.prank(alice);
        uint256 gasBefore = gasleft();
        token.burn(amount);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Burn gas used:", gasUsed);
        // Should be around 28,000-32,000 gas
        assertLt(gasUsed, 35000, "Burn should use less than 35k gas");
    }
    
    function test_GasUsage_BurnFrom() public {
        uint256 amount = 1000 * 10**18;
        
        // Setup allowance
        vm.prank(alice);
        token.approve(bob, amount);
        
        vm.prank(bob);
        uint256 gasBefore = gasleft();
        token.burnFrom(alice, amount);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("BurnFrom gas used:", gasUsed);
        // Should be around 35,000-40,000 gas
        assertLt(gasUsed, 45000, "BurnFrom should use less than 45k gas");
    }
    
    function test_GasUsage_ViewFunctions() public view {
        // View functions should use minimal gas
        token.name();
        token.symbol();
        token.decimals();
        token.totalSupply();
        token.balanceOf(alice);
        token.allowance(alice, bob);
        token.owner();
        token.hasOwner();
        
        // These are view functions, so gas usage is not measured in tests
        // but they should be very efficient (< 1000 gas each)
    }
}