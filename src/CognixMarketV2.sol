// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CognixMarket.sol";
import "./libraries/ReputationLib.sol";

contract CognixMarketV2 is CognixMarket {
    using ReputationLib for ReputationLib.AgentStats;
    
    mapping(address => ReputationLib.AgentStats) public agentStats;
    mapping(uint256 => uint256) public taskDeadlines;
    mapping(address => bool) public verifiedAgents;
    
    uint256 public constant DEADLINE_EXTENSION = 7 days;
    uint256 public platformFee = 250; // 2.5% in basis points
    
    event AgentVerified(address indexed agent);
    event DeadlineExtended(uint256 indexed taskId, uint256 newDeadline);
    event PlatformFeeUpdated(uint256 newFee);
    
    constructor(address _nativeToken) CognixMarket(_nativeToken) {}
    
    function createTaskWithDeadline(
        string calldata _metadataURI,
        uint256 _deadline
    ) external payable returns (uint256) {
        require(_deadline > block.timestamp, "Invalid deadline");
        uint256 taskId = createTask(_metadataURI);
        taskDeadlines[taskId] = _deadline;
        return taskId;
    }
    
    function verifyAgent(address _agent) external onlyOwner {
        verifiedAgents[_agent] = true;
        emit AgentVerified(_agent);
    }
    
    function extendDeadline(uint256 _taskId) external {
        require(tasks[_taskId].employer == msg.sender, "Only employer");
        require(taskDeadlines[_taskId] > 0, "No deadline set");
        taskDeadlines[_taskId] += DEADLINE_EXTENSION;
        emit DeadlineExtended(_taskId, taskDeadlines[_taskId]);
    }
    
    function setPlatformFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, "Fee too high"); // Max 10%
        platformFee = _fee;
        emit PlatformFeeUpdated(_fee);
    }
    
    function getAgentStats(address _agent) external view returns (
        uint256 totalTasks,
        uint256 completedTasks,
        uint256 disputedTasks,
        uint256 totalEarned,
        uint256 score,
        uint256 successRate
    ) {
        ReputationLib.AgentStats storage stats = agentStats[_agent];
        return (
            stats.totalTasks,
            stats.completedTasks,
            stats.disputedTasks,
            stats.totalEarned,
            stats.score,
            stats.getSuccessRate()
        );
    }
}