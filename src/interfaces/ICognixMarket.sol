// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICognixMarket {
    enum TaskStatus { Created, Assigned, ProofSubmitted, Completed, Cancelled, Disputed }

    struct Task {
        address employer;
        address assignee;
        string metadataURI;
        uint256 reward;
        TaskStatus status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Application {
        address agent;
        string proposalURI;
        uint256 appliedAt;
    }

    function createTask(string calldata _metadataURI) external payable returns (uint256);
    function applyForTask(uint256 _taskId, string calldata _proposalURI) external;
    function assignTask(uint256 _taskId, address _assignee) external;
}
