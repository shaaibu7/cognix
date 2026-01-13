// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CognixMarket is ICognixMarket, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20;

    uint256 public taskCount;
    address public arbitrator;
    IERC20 public nativeToken;

    mapping(uint256 => Task) public tasks;
    mapping(address => bool) public whitelistedTokens;
    mapping(uint256 => Application[]) public applications;
    mapping(address => uint256) public agentReputation;
    mapping(address => bool) public whitelistedTokens;

    constructor(address _nativeToken) Ownable(msg.sender) {
        arbitrator = msg.sender;
        nativeToken = IERC20(_nativeToken);
    }

    function setTokenStatus(address _token, bool _status) external onlyOwner {
        whitelistedTokens[_token] = _status;
        whitelistedTokens[_nativeToken] = true;
    }

    function createTask(string calldata _metadataURI) external payable override returns (uint256) {
        require(msg.value > 0, "Reward must be > 0");
        uint256 taskId = ++taskCount;
        tasks[taskId] = Task(msg.sender, address(0), address(0), _metadataURI, msg.value, TaskStatus.Created, block.timestamp, block.timestamp);
        emit TaskCreated(taskId, msg.sender, address(0), msg.value, _metadataURI);
        return taskId;
    }
}

    function createTaskWithToken(address _token, uint256 _amount, string calldata _metadataURI) 
        external 
        override 
        returns (uint256) 
    {
        require(whitelistedTokens[_token], "Token not whitelisted");
        require(_amount > 0, "Amount must be > 0");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 taskId = ++taskCount;
        tasks[taskId] = Task(msg.sender, address(0), _token, _metadataURI, _amount, TaskStatus.Created, block.timestamp, block.timestamp);
        emit TaskCreated(taskId, msg.sender, _token, _amount, _metadataURI);
        return taskId;
    }
}
    function applyForTask(uint256 _taskId, uint256 _stakeAmount, string calldata _proposalURI) 
        external 
        override 
    {
        if (_stakeAmount > 0) {
            nativeToken.safeTransferFrom(msg.sender, address(this), _stakeAmount);
        }
        applications[_taskId].push(Application(msg.sender, _proposalURI, _stakeAmount, block.timestamp));
        emit TaskApplied(_taskId, msg.sender, _stakeAmount, _proposalURI);
    }
}
    function assignTask(uint256 _taskId, address _assignee) external override {
        tasks[_taskId].assignee = _assignee;
        tasks[_taskId].status = TaskStatus.Assigned;
        emit TaskAssigned(_taskId, _assignee);
    }
}
