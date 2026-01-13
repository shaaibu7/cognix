// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ICognixMarket
 * @notice Interface for the Cognix AI Agent Task Marketplace
 */
interface ICognixMarket {
    enum TaskStatus { Created, Assigned, ProofSubmitted, Completed, Cancelled, Disputed }

    struct Task {
        address employer;
        address assignee;
        address token; // address(0) for ETH, otherwise ERC20
        string metadataURI;
        uint256 reward;
        TaskStatus status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Application {
        address agent;
        string proposalURI;
        uint256 stakedAmount; // Optional $CGX stake for quality assurance
        uint256 appliedAt;
    }

    event TaskCreated(uint256 indexed taskId, address indexed employer, address token, uint256 reward, string metadataURI);
    event TaskApplied(uint256 indexed taskId, address indexed agent, uint256 stakedAmount, string proposalURI);
    event TaskAssigned(uint256 indexed taskId, address indexed assignee);
    event ProofSubmitted(uint256 indexed taskId, string proofURI);
    event TaskCompleted(uint256 indexed taskId);
    event TaskCancelled(uint256 indexed taskId);
    event DisputeRaised(uint256 indexed taskId, address indexed raiser);
    event DisputeResolved(uint256 indexed taskId, bool completed);

    function createTask(string calldata _metadataURI) external payable returns (uint256);
    function createTaskWithToken(address _token, uint256 _amount, string calldata _metadataURI) external returns (uint256);
    function applyForTask(uint256 _taskId, uint256 _stakeAmount, string calldata _proposalURI) external;
    function assignTask(uint256 _taskId, address _assignee) external;
    function submitProof(uint256 _taskId, string calldata _proofURI) external;
    function completeTask(uint256 _taskId) external;
    function cancelTask(uint256 _taskId) external;
    function disputeTask(uint256 _taskId) external;
}
