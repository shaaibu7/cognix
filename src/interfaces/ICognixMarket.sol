// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICognixMarket {
    enum TaskStatus { Created, Assigned, ProofSubmitted, Completed, Cancelled, Disputed }

    struct Task {
        address employer;
        address assignee;
        address token;
        address token;
        string metadataURI;
        uint256 reward;
        TaskStatus status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Application {
        address agent;
        string proposalURI;
        uint256 stakedAmount;
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
}
}
}
