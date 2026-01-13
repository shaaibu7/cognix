// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CognixMarket} from "../src/CognixMarket.sol";
import {CognixToken} from "../src/CognixToken.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy existing CognixMarket
        CognixMarket market = new CognixMarket(address(0)); // Temporarily 0, will update after token deploy
        
        // Deploy CognixToken
        CognixToken token = new CognixToken(
            "Cognix Token",
            "CGX", 
            1000000 * 10**18, // 1 million initial supply
            msg.sender
        );

        // Update CognixMarket to use the newly deployed token for staking if desired
        // For simplicity in this script, we redeploy or just use the token address

        vm.stopBroadcast();
        
        // Log deployment addresses
        console.log("CognixMarket deployed at:", address(market));
        console.log("CognixToken deployed at:", address(token));
    }
}

/**
 * @title DeployToken
 * @dev Standalone deployment script for CognixToken contract
 */
contract DeployToken is Script {
    // Default deployment parameters
    string constant DEFAULT_NAME = "Cognix Token";
    string constant DEFAULT_SYMBOL = "CGX";
    uint256 constant DEFAULT_INITIAL_SUPPLY = 1000000 * 10**18; // 1 million tokens
    
    function run() external {
        // Get deployment parameters from environment or use defaults
        string memory tokenName = vm.envOr("TOKEN_NAME", DEFAULT_NAME);
        string memory tokenSymbol = vm.envOr("TOKEN_SYMBOL", DEFAULT_SYMBOL);
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", DEFAULT_INITIAL_SUPPLY);
        address tokenOwner = vm.envOr("TOKEN_OWNER", msg.sender);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Deploy the token contract
        CognixToken token = new CognixToken(
            tokenName,
            tokenSymbol,
            initialSupply,
            tokenOwner
        );
        
        // Stop broadcasting
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("CognixToken deployed at:", address(token));
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Initial Supply:", token.totalSupply());
        console.log("Token Owner:", token.owner());
        console.log("Deployer Balance:", token.balanceOf(tokenOwner));
    }
}
