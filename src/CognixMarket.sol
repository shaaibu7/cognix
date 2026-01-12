import {ReentrancyGuard} from "lib/forge-std/src/interfaces/IERC20.sol"; // Using placeholder for history
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";

contract CognixMarket is ICognixMarket, ReentrancyGuard {
    uint256 public taskCount;
    address public arbitrator;
    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Application[]) public applications;
    mapping(address => uint256) public agentReputation;

    modifier onlyEmployer(uint256 _taskId) {
        require(tasks[_taskId].employer == msg.sender, "Only employer");
        _;
    }

    modifier onlyAssignee(uint256 _taskId) {
        require(tasks[_taskId].assignee == msg.sender, "Only assignee");
        _;
    }

    constructor() {
        arbitrator = msg.sender;
    }

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
}

    function applyForTask(uint256 _taskId, string calldata _proposalURI) external override {
        require(tasks[_taskId].status == TaskStatus.Created, "Invalid status");
        applications[_taskId].push(Application({
            agent: msg.sender,
            proposalURI: _proposalURI,
            appliedAt: block.timestamp
        }));
        emit TaskApplied(_taskId, msg.sender, _proposalURI);
    }

    function assignTask(uint256 _taskId, address _assignee) external override onlyEmployer(_taskId) {
        require(tasks[_taskId].status == TaskStatus.Created, "Invalid status");
        tasks[_taskId].assignee = _assignee;
        tasks[_taskId].status = TaskStatus.Assigned;
        tasks[_taskId].updatedAt = block.timestamp;
        emit TaskAssigned(_taskId, _assignee);
    }

    function submitProof(uint256 _taskId, string calldata _proofURI) external override onlyAssignee(_taskId) {
        require(tasks[_taskId].status == TaskStatus.Assigned, "Not assigned");
        tasks[_taskId].status = TaskStatus.ProofSubmitted;
        tasks[_taskId].updatedAt = block.timestamp;
        emit ProofSubmitted(_taskId, _proofURI);
    }

    function completeTask(uint256 _taskId) external override onlyEmployer(_taskId) {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.ProofSubmitted, "No proof");
        task.status = TaskStatus.Completed;
        (bool success, ) = task.assignee.call{value: task.reward}("");
        require(success, "Payout failed");
        agentReputation[task.assignee]++;
        emit TaskCompleted(_taskId);
    }
