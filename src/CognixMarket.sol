// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";

contract CognixMarket is ICognixMarket {
    uint256 public taskCount;
    address public arbitrator;
    mapping(uint256 => Task) public tasks;

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
