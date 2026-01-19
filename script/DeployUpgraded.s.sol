// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/CognixToken.sol";
import "../src/CognixMarket.sol";

contract DeployUpgraded is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy CognixToken
        CognixToken token = new CognixToken(
            "Cognix Token",
            "CGX", 
            1000000000 * 1e18, // 1 billion tokens
            deployer
        );
        
        // Deploy CognixMarket
        CognixMarket market = new CognixMarket(address(token));
        
        // Setup initial configuration
        market.setTokenStatus(address(token), true);
        
        console.log("CognixToken deployed at:", address(token));
        console.log("CognixMarket deployed at:", address(market));
        console.log("Deployer:", deployer);
        console.log("Token supply:", token.totalSupply());
        
        vm.stopBroadcast();
    }
}