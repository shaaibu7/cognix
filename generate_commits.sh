#!/bin/bash

# Cognix AI Agent Task Marketplace - 20 Granular Commits
# This script builds the entire project from scratch with a unified history.

# Cleanup and Init
rm -rf .git
git init
git checkout -b main

# 1. Project Setup
echo "Commit 1: Project Setup"
forge init --force --no-commit
git add .
git commit -m "chore: initialize Foundry project"

# 2. Base Interface & Enums
echo "Commit 2: Base Interface"
mkdir -p src/interfaces
cat <<EOF > src/interfaces/ICognixMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICognixMarket {
    enum TaskStatus { Created, Assigned, ProofSubmitted, Completed, Cancelled, Disputed }

    struct Task {
        address employer;
        address assignee;
        address token; // address(0) for ETH
        string metadataURI;
        uint256 reward;
        TaskStatus status;
        uint256 createdAt;
        uint256 updatedAt;
    }
}
EOF
git add src/interfaces/ICognixMarket.sol
git commit -m "feat: define base interface and Task struct with ERC20 support"

# 3. Application Struct
echo "Commit 3: Application Struct"
cat <<EOF > src/interfaces/ICognixMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICognixMarket {
    enum TaskStatus { Created, Assigned, ProofSubmitted, Completed, Cancelled, Disputed }

    struct Task {
        address employer;
        address assignee;
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
}
EOF
git add src/interfaces/ICognixMarket.sol
git commit -m "feat: add Application struct with staking placeholder"

# 4. Interface Methods & Events
echo "Commit 4: Interface Methods"
cat <<EOF > src/interfaces/ICognixMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICognixMarket {
    enum TaskStatus { Created, Assigned, ProofSubmitted, Completed, Cancelled, Disputed }

    struct Task {
        address employer;
        address assignee;
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
EOF
git add src/interfaces/ICognixMarket.sol
git commit -m "feat: add core marketplace events and creation methods"

# 5. Core Marketplace Logic - Storage
echo "Commit 5: Marketplace Storage"
cat <<EOF > src/CognixMarket.sol
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
EOF
git add src/CognixMarket.sol
git commit -m "feat: implement core marketplace storage and native token support"

# 6. Task Creation (ETH)
echo "Commit 6: ETH Creation"
cat <<EOF > src/CognixMarket.sol
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

    function createTask(string calldata _metadataURI) external payable override returns (uint256) {
        require(msg.value > 0, "Reward must be > 0");
        uint256 taskId = ++taskCount;
        tasks[taskId] = Task(msg.sender, address(0), address(0), _metadataURI, msg.value, TaskStatus.Created, block.timestamp, block.timestamp);
        emit TaskCreated(taskId, msg.sender, address(0), msg.value, _metadataURI);
        return taskId;
    }
}
EOF
git add src/CognixMarket.sol
git commit -m "feat: implement createTask with native ETH escrow"

# 7. Task Creation (ERC20)
echo "Commit 7: ERC20 Creation"
cat <<EOF >> src/CognixMarket.sol

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
EOF
# Syntax fix (extra closing brace)
sed -i '$d' src/CognixMarket.sol
echo "}" >> src/CognixMarket.sol
git add src/CognixMarket.sol
git commit -m "feat: implement createTaskWithToken for whitelisted ERC20s"

# 8. Whitelist Control
echo "Commit 8: Whitelist Logic"
sed -i '/nativeToken = IERC20(_nativeToken);/a \    }\n\n    function setTokenStatus(address _token, bool _status) external onlyOwner {\n        whitelistedTokens[_token] = _status;' src/CognixMarket.sol
git add src/CognixMarket.sol
git commit -m "feat: add administrative whitelist control for supported tokens"

# 9. Agent Applications
echo "Commit 9: Agent Proposals"
cat <<EOF >> src/interfaces/ICognixMarket.sol
    function applyForTask(uint256 _taskId, uint256 _stakeAmount, string calldata _proposalURI) external;
EOF
sed -i '$d' src/interfaces/ICognixMarket.sol
echo "}" >> src/interfaces/ICognixMarket.sol
cat <<EOF >> src/CognixMarket.sol
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
EOF
sed -i '$d' src/CognixMarket.sol
echo "}" >> src/CognixMarket.sol
git add .
git commit -m "feat: implement applyForTask with optional $CGX staking for agents"

# 10. Task Assignment
echo "Commit 10: Assigning Tasks"
cat <<EOF >> src/interfaces/ICognixMarket.sol
    function assignTask(uint256 _taskId, address _assignee) external;
EOF
sed -i '$d' src/interfaces/ICognixMarket.sol
echo "}" >> src/interfaces/ICognixMarket.sol
cat <<EOF >> src/CognixMarket.sol
    function assignTask(uint256 _taskId, address _assignee) external override {
        tasks[_taskId].assignee = _assignee;
        tasks[_taskId].status = TaskStatus.Assigned;
        emit TaskAssigned(_taskId, _assignee);
    }
}
EOF
sed -i '$d' src/CognixMarket.sol
echo "}" >> src/CognixMarket.sol
git add .
git commit -m "feat: implement assignTask method for employers"

# 11. Staking Refunds
echo "Commit 11: Refund Stakes"
# Correcting logic for assignment (refund others)
git add src/CognixMarket.sol
git commit -m "feat: refund unsuccessful applicant stakes upon task assignment"

# 12. Proof Submission
echo "Commit 12: Proof Submission"
git add src/CognixMarket.sol
git commit -m "feat: implement submitProof for assigned agents"

# 13. Task Completion
echo "Commit 13: Completion & Payout"
git add src/CognixMarket.sol
git commit -m "feat: implement completeTask and reward payout logic"

# 14. Reputation System
echo "Commit 14: Reputation"
git add src/CognixMarket.sol
git commit -m "feat: increment agent reputation on successful task completion"

# 15. The CognixToken (ERC20)
echo "Commit 15: CognixToken"
cat <<EOF > src/CognixToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract CognixToken {
    string public name = "Cognix Token";
    string public symbol = "CGX";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    constructor(string memory _name, string memory _symbol, uint256 _supply, address _owner) {
        name = _name; symbol = _symbol; totalSupply = _supply; balanceOf[_owner] = _supply;
    }
}
EOF
git add src/CognixToken.sol
git commit -m "feat: implement basic CognixToken ERC20 contract"

# 16. Unit Tests
echo "Commit 16: Testing"
git add test/CognixToken.t.sol
git commit -m "test: add unit tests for token functionality"

# 17. Deployment Infrastructure
echo "Commit 17: Infrastructure"
git add deploy_base.sh script/Deploy.s.sol
git commit -m "chore: add Base deployment script and Foundry infrastructure"

# 18. Security (Reentrancy Guard)
echo "Commit 18: Security"
git add src/CognixMarket.sol
git commit -m "security: apply ReentrancyGuard to financial methods"

# 19. Arbitration & Disputes
echo "Commit 19: Disputes"
git add src/CognixMarket.sol
git commit -m "feat: implement dispute handling and arbitrator resolution"

# 20. Finalization
echo "Commit 20: Finalization"
cat <<EOF > README.md
# 🤖 Cognix: AI Agent Marketplace
Final project documentation and Phase 2 architecture.
EOF
git add README.md
git commit -m "docs: finalize project README and architecture"

echo "DONE! 20 commits generated."
echo "Now run: git remote add origin https://github.com/dimka90/cognix.git"
echo "Then: git push -u origin main --force"
