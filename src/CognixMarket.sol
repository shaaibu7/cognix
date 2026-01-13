// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICognixMarket} from "./interfaces/ICognixMarket.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CognixMarket is ICognixMarket, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    uint256 public taskCount;
    address public arbitrator;
    IERC20 public nativeToken;

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Application[]) public applications;
    mapping(address => uint256) public agentReputation;
    mapping(address => bool) public whitelistedTokens;

    constructor(address _nativeToken) Ownable(msg.sender) {
        arbitrator = msg.sender;
        nativeToken = IERC20(_nativeToken);
        whitelistedTokens[_nativeToken] = true;
    }
}
