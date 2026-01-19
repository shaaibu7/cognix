// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract CognixMarket is ICognixMarket, ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    uint256 public taskCount;
    address public arbitrator;
    IERC20 public nativeToken;

    mapping(uint256 => Task) public tasks;
    mapping(address => bool) public whitelistedTokens;
    mapping(uint256 => Application[]) public applications;
    mapping(address => uint256) public agentReputation;

    constructor(address _nativeToken) Ownable(msg.sender) {
        arbitrator = msg.sender;
        nativeToken = IERC20(_nativeToken);
        whitelistedTokens[_nativeToken] = true;
    }

    function setTokenStatus(address _token, bool _status) external onlyOwner {
        whitelistedTokens[_token] = _status;
        emit TokenWhitelistUpdated(_token, _status);
    }

    function createTask(string calldata _metadataURI) external payable override nonReentrant whenNotPaused returns (uint256) {
        require(msg.value > 0, "Reward must be > 0");
        uint256 taskId = ++taskCount;
        tasks[taskId] = Task({
            employer: msg.sender,
            assignee: address(0),
            token: address(0),
            metadataURI: _metadataURI,
            reward: msg.value,
            status: TaskStatus.Created,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });
        emit TaskCreated(taskId, msg.sender, address(0), msg.value, _metadataURI);
        return taskId;
    }

    function createTaskWithToken(address _token, uint256 _amount, string calldata _metadataURI) 
        external 
        override 
        nonReentrant 
        whenNotPaused 
        returns (uint256) 
    {
        require(whitelistedTokens[_token], "Token not whitelisted");
        require(_amount > 0, "Amount must be > 0");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 taskId = ++taskCount;
        tasks[taskId] = Task({
            employer: msg.sender,
            assignee: address(0),
            token: _token,
            metadataURI: _metadataURI,
            reward: _amount,
            status: TaskStatus.Created,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });
        emit TaskCreated(taskId, msg.sender, _token, _amount, _metadataURI);
        return taskId;
    }
    function applyForTask(uint256 _taskId, uint256 _stakeAmount, string calldata _proposalURI) 
        external 
        override 
        nonReentrant 
        whenNotPaused 
    {
        require(_taskId > 0 && _taskId <= taskCount, "Invalid task ID");
        require(tasks[_taskId].status == TaskStatus.Created, "Task not available");
        
        if (_stakeAmount > 0) {
            nativeToken.safeTransferFrom(msg.sender, address(this), _stakeAmount);
        }
        applications[_taskId].push(Application({
            agent: msg.sender,
            proposalURI: _proposalURI,
            stakedAmount: _stakeAmount,
            appliedAt: block.timestamp
        }));
        emit TaskApplied(_taskId, msg.sender, _stakeAmount, _proposalURI);
    }
    function assignTask(uint256 _taskId, address _assignee) external override whenNotPaused {
        require(_taskId > 0 && _taskId <= taskCount, "Invalid task ID");
        require(tasks[_taskId].employer == msg.sender, "Only employer can assign");
        require(tasks[_taskId].status == TaskStatus.Created, "Task not available for assignment");
        require(_assignee != address(0), "Invalid assignee");
        
        tasks[_taskId].assignee = _assignee;
        tasks[_taskId].status = TaskStatus.Assigned;
        tasks[_taskId].updatedAt = block.timestamp;
        emit TaskAssigned(_taskId, _assignee);
    }

    function submitProof(uint256 _taskId, string calldata _proofURI) external whenNotPaused {
        require(_taskId > 0 && _taskId <= taskCount, "Invalid task ID");
        require(tasks[_taskId].assignee == msg.sender, "Only assignee can submit proof");
        require(tasks[_taskId].status == TaskStatus.Assigned, "Task not assigned");
        
        tasks[_taskId].status = TaskStatus.ProofSubmitted;
        tasks[_taskId].updatedAt = block.timestamp;
        emit ProofSubmitted(_taskId, _proofURI);
    }
    function completeTask(uint256 _taskId) external nonReentrant whenNotPaused {
        require(_taskId > 0 && _taskId <= taskCount, "Invalid task ID");
        require(tasks[_taskId].employer == msg.sender, "Only employer can complete");
        require(tasks[_taskId].status == TaskStatus.ProofSubmitted, "Proof not submitted");
        
        Task storage task = tasks[_taskId];
        task.status = TaskStatus.Completed;
        task.updatedAt = block.timestamp;
        
        // Transfer reward to assignee
        if (task.token == address(0)) {
            payable(task.assignee).transfer(task.reward);
        } else {
            IERC20(task.token).safeTransfer(task.assignee, task.reward);
        }
        
        // Update reputation
        agentReputation[task.assignee] += task.reward / 1e15; // Weighted by task value
        
        emit TaskCompleted(_taskId);
    }

    function cancelTask(uint256 _taskId) external nonReentrant whenNotPaused {
        require(_taskId > 0 && _taskId <= taskCount, "Invalid task ID");
        require(tasks[_taskId].employer == msg.sender, "Only employer can cancel");
        require(tasks[_taskId].status == TaskStatus.Created || tasks[_taskId].status == TaskStatus.Assigned, "Cannot cancel task");
        
        Task storage task = tasks[_taskId];
        task.status = TaskStatus.Cancelled;
        task.updatedAt = block.timestamp;
        
        // Refund employer
        if (task.token == address(0)) {
            payable(task.employer).transfer(task.reward);
        } else {
            IERC20(task.token).safeTransfer(task.employer, task.reward);
        }
        
        emit TaskCancelled(_taskId);
    }