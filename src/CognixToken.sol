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
