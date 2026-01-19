// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CognixMarket.sol";
import "../src/CognixToken.sol";

contract CognixMarketTest is Test {
    CognixMarket public market;
    CognixToken public token;
    
    address public employer = address(0x1);
    address public agent = address(0x2);
    address public arbitrator = address(0x3);
    
    function setUp() public {
        token = new CognixToken("Cognix Token", "CGX", 1000000 * 1e18, address(this));
        market = new CognixMarket(address(token));
        
        // Setup test accounts
        vm.deal(employer, 10 ether);
        vm.deal(agent, 10 ether);
        token.transfer(employer, 1000 * 1e18);
        token.transfer(agent, 1000 * 1e18);
        
        // Whitelist token
        market.setTokenStatus(address(token), true);
    }
    
    function testCreateTaskWithETH() public {
        vm.startPrank(employer);
        uint256 taskId = market.createTask{value: 1 ether}("ipfs://metadata");
        
        (address taskEmployer, address assignee, address taskToken, string memory metadataURI, uint256 reward, ICognixMarket.TaskStatus status,,) = market.tasks(taskId);
        
        assertEq(taskEmployer, employer);
        assertEq(assignee, address(0));
        assertEq(taskToken, address(0));
        assertEq(reward, 1 ether);
        assertTrue(status == ICognixMarket.TaskStatus.Created);
        vm.stopPrank();
    }
    
    function testCreateTaskWithToken() public {
        vm.startPrank(employer);
        token.approve(address(market), 100 * 1e18);
        uint256 taskId = market.createTaskWithToken(address(token), 100 * 1e18, "ipfs://metadata");
        
        (address taskEmployer, address assignee, address taskToken, string memory metadataURI, uint256 reward, ICognixMarket.TaskStatus status,,) = market.tasks(taskId);
        
        assertEq(taskEmployer, employer);
        assertEq(taskToken, address(token));
        assertEq(reward, 100 * 1e18);
        assertTrue(status == ICognixMarket.TaskStatus.Created);
        vm.stopPrank();
    }
    
    function testApplyForTask() public {
        vm.prank(employer);
        uint256 taskId = market.createTask{value: 1 ether}("ipfs://metadata");
        
        vm.startPrank(agent);
        token.approve(address(market), 10 * 1e18);
        market.applyForTask(taskId, 10 * 1e18, "ipfs://proposal");
        
        ICognixMarket.Application[] memory apps = market.getTaskApplications(taskId);
        assertEq(apps.length, 1);
        assertEq(apps[0].agent, agent);
        assertEq(apps[0].stakedAmount, 10 * 1e18);
        vm.stopPrank();
    }
}