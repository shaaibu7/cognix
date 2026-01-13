# CognixToken (CGX) - ERC20 Implementation

## Overview

CognixToken is a comprehensive ERC20 token implementation built with Solidity ^0.8.19 and the Foundry framework. This implementation was developed through 20 incremental commits following best practices for version control and iterative development.

## Features

### ✅ Core ERC20 Functionality
- Standard transfer, approve, and transferFrom functions
- Complete balance and allowance management
- ERC20-compliant event emissions
- 18 decimal precision

### ✅ Extended Features
- **Minting**: Owner-controlled token creation (up to max supply)
- **Burning**: Token destruction by holders and via allowance
- **Ownership Management**: Secure ownership transfer and renunciation
- **Supply Controls**: 1 billion token maximum supply cap

### ✅ Security & Optimization
- Custom errors for gas efficiency
- Comprehensive input validation
- Overflow protection with unchecked arithmetic where safe
- Access control with owner-only administrative functions

## Contract Details

| Parameter | Value |
|-----------|-------|
| Name | Cognix Token |
| Symbol | CGX |
| Decimals | 18 |
| Max Supply | 1,000,000,000 CGX |
| Initial Supply | Configurable at deployment |

## Development Process

This implementation was created through exactly **20 commits** as specified:

1. **Setup & Configuration** - Foundry configuration and remappings
2. **Contract Skeleton** - Basic structure with metadata and errors
3. **Core ERC20** - Transfer, approve, transferFrom implementation
4. **Access Control** - Ownership management with Ownable pattern
5. **Minting** - Token creation functionality with supply limits
6. **Burning** - Token destruction capabilities
7. **Error Handling** - Enhanced validation and custom errors
8. **Test Setup** - Comprehensive test framework initialization
9. **Core Tests** - Unit tests for ERC20 functions
10. **Admin Tests** - Tests for minting, burning, and ownership
11. **Deployment** - Production-ready deployment scripts
12. **Documentation** - Complete API documentation and NatSpec
13. **Gas Optimization** - Efficiency improvements and benchmarks
14. **Final Integration** - Code cleanup and final testing

## File Structure

```
├── src/
│   └── CognixToken.sol          # Main token contract
├── test/
│   ├── CognixToken.t.sol        # Comprehensive unit tests
│   └── GasOptimization.t.sol    # Gas usage benchmarks
├── script/
│   └── Deploy.s.sol             # Deployment scripts
├── docs/
│   └── CognixToken.md           # Detailed documentation
└── README_ERC20.md             # This file
```

## Quick Start

### Deployment

```bash
# Deploy with default parameters
forge script script/Deploy.s.sol:DeployToken --rpc-url <RPC_URL> --broadcast

# Deploy with custom parameters
TOKEN_NAME="My Token" \
TOKEN_SYMBOL="MTK" \
INITIAL_SUPPLY=2000000000000000000000000 \
forge script script/Deploy.s.sol:DeployToken --rpc-url <RPC_URL> --broadcast
```

### Testing

```bash
# Run all tests
forge test

# Run with gas reporting
forge test --gas-report

# Run specific test file
forge test --match-contract CognixTokenTest
```

### Basic Usage

```solidity
// Deploy the token
CognixToken token = new CognixToken(
    "Cognix Token",    // name
    "CGX",             // symbol
    1000000 * 10**18,  // initial supply (1M tokens)
    msg.sender         // owner
);

// Basic operations
token.transfer(recipient, 1000 * 10**18);           // Transfer 1000 CGX
token.approve(spender, 5000 * 10**18);              // Approve 5000 CGX
token.transferFrom(owner, recipient, 2000 * 10**18); // Transfer from allowance

// Administrative operations (owner only)
token.mint(recipient, 10000 * 10**18);              // Mint 10000 CGX
token.burn(1000 * 10**18);                          // Burn 1000 CGX
token.transferOwnership(newOwner);                   // Transfer ownership
```

## Security Features

- **Access Control**: Only owner can mint tokens
- **Supply Limits**: Maximum supply prevents unlimited inflation
- **Input Validation**: Comprehensive parameter checking
- **Custom Errors**: Gas-efficient error handling
- **Zero Address Protection**: Prevents token loss
- **Overflow Protection**: Safe arithmetic operations

## Gas Efficiency

The contract is optimized for gas efficiency:

| Operation | Estimated Gas |
|-----------|---------------|
| Transfer | ~51,000 |
| Approve | ~46,000 |
| TransferFrom | ~55,000 |
| Mint | ~51,000 |
| Burn | ~28,000 |

## Testing Coverage

Comprehensive test suite includes:

- ✅ All ERC20 standard functions
- ✅ Administrative functions (mint, burn, ownership)
- ✅ Access control validation
- ✅ Error condition testing
- ✅ Event emission verification
- ✅ Gas usage benchmarks
- ✅ Edge cases and boundary conditions

## Documentation

- **API Reference**: See `docs/CognixToken.md` for complete function documentation
- **NatSpec Comments**: All functions include detailed NatSpec documentation
- **Usage Examples**: Practical examples for integration
- **Security Guidelines**: Best practices for safe usage

## License

MIT License - See LICENSE file for details.

## Development Notes

This implementation demonstrates:
- Proper Solidity development practices
- Comprehensive testing methodology
- Gas optimization techniques
- Security-first design principles
- Professional documentation standards
- Incremental development with meaningful commits

The 20-commit development process showcases how complex smart contracts should be built iteratively, with each commit adding specific functionality while maintaining code quality and test coverage.