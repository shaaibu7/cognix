// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library ReputationLib {
    struct AgentStats {
        uint256 totalTasks;
        uint256 completedTasks;
        uint256 disputedTasks;
        uint256 totalEarned;
        uint256 score;
    }
    
    function calculateReputationIncrease(uint256 taskValue) internal pure returns (uint256) {
        // Base reputation increase with task value weighting
        return (taskValue / 1e15) + 10; // Minimum 10 points per task
    }
    
    function calculateReputationDecrease(uint256 taskValue) internal pure returns (uint256) {
        // Penalty for disputed tasks
        return (taskValue / 1e15) + 5; // Minimum 5 point penalty
    }
    
    function updateStats(
        AgentStats storage stats,
        uint256 taskValue,
        bool completed,
        bool disputed
    ) internal {
        stats.totalTasks++;
        stats.totalEarned += taskValue;
        
        if (completed && !disputed) {
            stats.completedTasks++;
            stats.score += calculateReputationIncrease(taskValue);
        } else if (disputed) {
            stats.disputedTasks++;
            uint256 penalty = calculateReputationDecrease(taskValue);
            stats.score = stats.score > penalty ? stats.score - penalty : 0;
        }
    }
    
    function getSuccessRate(AgentStats storage stats) internal view returns (uint256) {
        if (stats.totalTasks == 0) return 0;
        return (stats.completedTasks * 100) / stats.totalTasks;
    }
}