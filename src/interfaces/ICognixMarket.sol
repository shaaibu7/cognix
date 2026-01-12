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

    event TaskCreated(uint256 indexed taskId, address indexed employer, uint256 reward, string metadataURI);
    event TaskApplied(uint256 indexed taskId, address indexed agent, string proposalURI);
    event TaskAssigned(uint256 indexed taskId, address indexed assignee);
    event ProofSubmitted(uint256 indexed taskId, string proofURI);
    event TaskCompleted(uint256 indexed taskId);

    function createTask(string calldata _metadataURI) external payable returns (uint256);
    function applyForTask(uint256 _taskId, string calldata _proposalURI) external;
    function assignTask(uint256 _taskId, address _assignee) external;
    function submitProof(uint256 _taskId, string calldata _proofURI) external;
    function completeTask(uint256 _taskId) external;
}
