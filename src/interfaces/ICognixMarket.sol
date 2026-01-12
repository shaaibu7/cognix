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
}
