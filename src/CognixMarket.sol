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
}
