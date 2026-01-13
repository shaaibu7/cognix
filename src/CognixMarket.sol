// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CognixMarket
 * @notice A decentralized marketplace for AI Agent tasks with ETH/ERC20 support and staking.
 */
contract CognixMarket is ICognixMarket, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    uint256 public taskCount;
    address public arbitrator;
    IERC20 public nativeToken; // Default $CGX token for staking

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Application[]) public applications;
    mapping(address => uint256) public agentReputation;
    mapping(address => bool) public whitelistedTokens;

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

    constructor(address _nativeToken) Ownable(msg.sender) {
        arbitrator = msg.sender;
        nativeToken = IERC20(_nativeToken);
        whitelistedTokens[_nativeToken] = true;
    }

    function setArbitrator(address _arbitrator) external onlyOwner {
        arbitrator = _arbitrator;
    }

    function setTokenStatus(address _token, bool _status) external onlyOwner {
        whitelistedTokens[_token] = _status;
    }

    /**
     * @notice Create a task with ETH escrow.
     */
    function createTask(string calldata _metadataURI) external payable override returns (uint256) {
        require(msg.value > 0, "Reward must be > 0");
        return _createTask(address(0), msg.value, _metadataURI);
    }

    /**
     * @notice Create a task with ERC20 escrow.
     */
    function createTaskWithToken(address _token, uint256 _amount, string calldata _metadataURI) 
        external 
        override 
        returns (uint256) 
    {
        require(whitelistedTokens[_token], "Token not whitelisted");
        require(_amount > 0, "Amount must be > 0");

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        return _createTask(_token, _amount, _metadataURI);
    }

    function _createTask(address _token, uint256 _amount, string calldata _metadataURI) internal returns (uint256) {
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

    /**
     * @notice Agents apply for a task, optionally staking $CGX for quality assurance.
     */
    function applyForTask(uint256 _taskId, uint256 _stakeAmount, string calldata _proposalURI) 
        external 
        override 
        inStatus(_taskId, TaskStatus.Created) 
    {
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

    /**
     * @notice Employer assigns the task.
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

        // Refund all other applicants their stakes
        Application[] storage apps = applications[_taskId];
        for (uint256 i = 0; i < apps.length; i++) {
            if (apps[i].agent != _assignee && apps[i].stakedAmount > 0) {
                nativeToken.safeTransfer(apps[i].agent, apps[i].stakedAmount);
                apps[i].stakedAmount = 0;
            }
        }

        emit TaskAssigned(_taskId, _assignee);
    }

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

        _payout(task.assignee, task.token, task.reward);
        _refundStake(_taskId, task.assignee);

        emit TaskCompleted(_taskId);
    }

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

        _payout(task.employer, task.token, task.reward);

        // Refund all applicants
        Application[] storage apps = applications[_taskId];
        for (uint256 i = 0; i < apps.length; i++) {
            if (apps[i].stakedAmount > 0) {
                nativeToken.safeTransfer(apps[i].agent, apps[i].stakedAmount);
                apps[i].stakedAmount = 0;
            }
        }

        emit TaskCancelled(_taskId);
    }

    function disputeTask(uint256 _taskId) external override {
        Task storage task = tasks[_taskId];
        require(msg.sender == task.employer || msg.sender == task.assignee, "Not authorized");
        require(task.status == TaskStatus.Assigned || task.status == TaskStatus.ProofSubmitted, "Invalid status");

        task.status = TaskStatus.Disputed;
        task.updatedAt = block.timestamp;

        emit DisputeRaised(_taskId, msg.sender);
    }

    function resolveDispute(uint256 _taskId, bool _payAgent) external nonReentrant {
        require(msg.sender == arbitrator, "Only arbitrator");
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Disputed, "Not disputed");

        if (_payAgent) {
            task.status = TaskStatus.Completed;
            agentReputation[task.assignee]++;
            _payout(task.assignee, task.token, task.reward);
            _refundStake(_taskId, task.assignee);
        } else {
            task.status = TaskStatus.Cancelled;
            _payout(task.employer, task.token, task.reward);
            // In case of agent failure, we could slash the stake. For now, just refund to be safe.
             _refundStake(_taskId, task.assignee);
        }

        emit DisputeResolved(_taskId, _payAgent);
    }

    function _payout(address _to, address _token, uint256 _amount) internal {
        if (_token == address(0)) {
            (bool success, ) = _to.call{value: _amount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    function _refundStake(uint256 _taskId, address _agent) internal {
        Application[] storage apps = applications[_taskId];
        for (uint256 i = 0; i < apps.length; i++) {
            if (apps[i].agent == _agent && apps[i].stakedAmount > 0) {
                nativeToken.safeTransfer(_agent, apps[i].stakedAmount);
                apps[i].stakedAmount = 0;
            }
        }
    }

    function getApplications(uint256 _taskId) external view returns (Application[] memory) {
        return applications[_taskId];
    }
}
