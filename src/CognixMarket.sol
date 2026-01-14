// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CognixMarket
 * @notice A decentralized marketplace for AI Agent tasks with escrow and arbitration.
 */
contract CognixMarket is ICognixMarket, ReentrancyGuard, Ownable {
    uint256 public taskCount;
    address public arbitrator;
    uint256 public platformFee; // Fee percentage (basis points, e.g., 250 = 2.5%)

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Application[]) public applications;
    mapping(address => uint256) public agentReputation; // Count of successfully completed tasks
    mapping(address => uint256) public agentEarnings; // Total earnings per agent

    modifier onlyEmployer(uint256 _taskId) {
        require(tasks[_taskId].employer == msg.sender, "Only employer");
        _;
    }

    modifier onlyAssignee(uint256 _taskId) {
        require(tasks[_taskId].assignee == msg.sender, "Only assignee");
        _;
    }

    modifier inStatus(uint256 _taskId, TaskStatus _status) {
        require(tasks[_taskId].status == _status, "Invalid task status");
        _;
    }

    constructor() Ownable(msg.sender) {
        arbitrator = msg.sender;
        platformFee = 250; // Default 2.5% fee
    }

    function setArbitrator(address _arbitrator) external onlyOwner {
        arbitrator = _arbitrator;
    }

    function setPlatformFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1000, "Fee too high"); // Max 10%
        platformFee = _fee;
    }

    /**
     * @notice Create a new task and escrow the reward.
     */
    function createTask(string calldata _metadataURI) external payable override returns (uint256) {
        require(msg.value > 0, "Reward must be > 0");

        uint256 taskId = ++taskCount;
        tasks[taskId] = Task({
            employer: msg.sender,
            assignee: address(0),
            metadataURI: _metadataURI,
            reward: msg.value,
            status: TaskStatus.Created,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        emit TaskCreated(taskId, msg.sender, msg.value, _metadataURI);
        return taskId;
    }

    /**
     * @notice Agents apply for a task with a proposal.
     */
    function applyForTask(uint256 _taskId, string calldata _proposalURI) 
        external 
        override 
        inStatus(_taskId, TaskStatus.Created) 
    {
        applications[_taskId].push(Application({
            agent: msg.sender,
            proposalURI: _proposalURI,
            appliedAt: block.timestamp
        }));

        emit TaskApplied(_taskId, msg.sender, _proposalURI);
    }

    /**
     * @notice Employer assigns the task to a specific agent.
     */
    function assignTask(uint256 _taskId, address _assignee) 
        external 
        override 
        onlyEmployer(_taskId) 
        inStatus(_taskId, TaskStatus.Created) 
    {
        tasks[_taskId].assignee = _assignee;
        tasks[_taskId].status = TaskStatus.Assigned;
        tasks[_taskId].updatedAt = block.timestamp;

        emit TaskAssigned(_taskId, _assignee);
    }

    /**
     * @notice Assignee submits proof of work (metadata URI).
     */
    function submitProof(uint256 _taskId, string calldata _proofURI) 
        external 
        override 
        onlyAssignee(_taskId) 
        inStatus(_taskId, TaskStatus.Assigned) 
    {
        tasks[_taskId].status = TaskStatus.ProofSubmitted;
        tasks[_taskId].updatedAt = block.timestamp;

        emit ProofSubmitted(_taskId, _proofURI);
    }

    /**
     * @notice Employer completes the task and releases funds.
     */
    function completeTask(uint256 _taskId) 
        external 
        override 
        onlyEmployer(_taskId) 
        nonReentrant 
    {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.ProofSubmitted || task.status == TaskStatus.Assigned, "Cannot complete");

        task.status = TaskStatus.Completed;
        task.updatedAt = block.timestamp;
        agentReputation[task.assignee]++;

        uint256 fee = (task.reward * platformFee) / 10000;
        uint256 agentPayment = task.reward - fee;
        
        agentEarnings[task.assignee] += agentPayment;

        (bool success, ) = task.assignee.call{value: agentPayment}("");
        require(success, "Transfer failed");

        emit TaskCompleted(_taskId);
    }

    /**
     * @notice Employer cancels the task and gets a refund (only if not assigned).
     */
    function cancelTask(uint256 _taskId) 
        external 
        override 
        onlyEmployer(_taskId) 
        inStatus(_taskId, TaskStatus.Created) 
        nonReentrant 
    {
        Task storage task = tasks[_taskId];
        task.status = TaskStatus.Cancelled;
        task.updatedAt = block.timestamp;

        (bool success, ) = task.employer.call{value: task.reward}("");
        require(success, "Refund failed");

        emit TaskCancelled(_taskId);
    }

    /**
     * @notice Either party can raise a dispute.
     */
    function disputeTask(uint256 _taskId) external override {
        Task storage task = tasks[_taskId];
        require(msg.sender == task.employer || msg.sender == task.assignee, "Not authorized");
        require(task.status == TaskStatus.Assigned || task.status == TaskStatus.ProofSubmitted, "Invalid status for dispute");

        task.status = TaskStatus.Disputed;
        task.updatedAt = block.timestamp;

        emit DisputeRaised(_taskId, msg.sender);
    }

    /**
     * @notice Arbitrator resolves the dispute.
     */
    function resolveDispute(uint256 _taskId, bool _payAgent) external nonReentrant {
        require(msg.sender == arbitrator, "Only arbitrator");
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Disputed, "Not disputed");

        if (_payAgent) {
            task.status = TaskStatus.Completed;
            agentReputation[task.assignee]++;
            (bool success, ) = task.assignee.call{value: task.reward}("");
            require(success, "Payment failed");
        } else {
            task.status = TaskStatus.Cancelled;
            (bool success, ) = task.employer.call{value: task.reward}("");
            require(success, "Refund failed");
        }

        emit DisputeResolved(_taskId, _payAgent);
    }

    /**
     * @notice View functions for applications and task details.
     */
    function getApplications(uint256 _taskId) external view returns (Application[] memory) {
        return applications[_taskId];
    }

    // Required by ICognixMarket but implemented via automatic getters for tasks
}
