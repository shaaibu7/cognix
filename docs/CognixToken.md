# CognixToken Documentation

## Overview

CognixToken (CGX) is a comprehensive ERC20 token implementation built with Solidity ^0.8.19 and the Foundry framework. It provides standard ERC20 functionality along with additional features like minting, burning, and robust access control.

## Features

### Core ERC20 Functionality
- **Transfer**: Send tokens between addresses
- **Approve**: Grant spending allowances to other addresses
- **TransferFrom**: Spend tokens on behalf of another address (with allowance)
- **Balance Queries**: Check token balances and allowances
- **Metadata**: Token name, symbol, and decimals

### Extended Features
- **Minting**: Owner can create new tokens (up to max supply)
- **Burning**: Token holders can destroy their tokens
- **BurnFrom**: Burn tokens from another address (with allowance)
- **Ownership Management**: Transfer or renounce contract ownership
- **Supply Limits**: Maximum supply cap of 1 billion tokens

### Security Features
- **Custom Errors**: Gas-efficient error handling
- **Access Control**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter validation
- **Overflow Protection**: Built-in arithmetic safety

## Contract Details

### Token Parameters
- **Name**: Cognix Token
- **Symbol**: CGX
- **Decimals**: 18
- **Max Supply**: 1,000,000,000 CGX (1 billion tokens)
- **Initial Supply**: Configurable at deployment

### Contract Address
The contract will be deployed on supported networks. Check the deployment logs for specific addresses.

## API Reference

### View Functions

#### `name() → string`
Returns the name of the token.

#### `symbol() → string`
Returns the symbol of the token.

#### `decimals() → uint8`
Returns the number of decimals (always 18).

#### `totalSupply() → uint256`
Returns the total token supply in circulation.

#### `balanceOf(address account) → uint256`
Returns the token balance of the specified account.

#### `allowance(address owner, address spender) → uint256`
Returns the remaining allowance that spender can spend on behalf of owner.

#### `owner() → address`
Returns the current owner of the contract.

#### `hasOwner() → bool`
Returns true if the contract has an owner, false if ownership was renounced.

### Core ERC20 Functions

#### `transfer(address to, uint256 amount) → bool`
Transfers tokens from caller to the specified address.

**Parameters:**
- `to`: Recipient address
- `amount`: Amount of tokens to transfer

**Returns:** `true` if successful

**Reverts:**
- `InvalidAddress`: If `to` is zero address
- `InsufficientBalance`: If caller has insufficient balance

#### `approve(address spender, uint256 amount) → bool`
Sets allowance for spender to spend caller's tokens.

**Parameters:**
- `spender`: Address authorized to spend tokens
- `amount`: Maximum amount spender can spend

**Returns:** `true` if successful

**Reverts:**
- `InvalidAddress`: If `spender` is zero address

#### `transferFrom(address from, address to, uint256 amount) → bool`
Transfers tokens from one address to another using allowance.

**Parameters:**
- `from`: Address to transfer tokens from
- `to`: Address to transfer tokens to
- `amount`: Amount of tokens to transfer

**Returns:** `true` if successful

**Reverts:**
- `InvalidAddress`: If `from` or `to` is zero address
- `InsufficientBalance`: If `from` has insufficient balance
- `InsufficientAllowance`: If caller has insufficient allowance

### Administrative Functions

#### `mint(address to, uint256 amount)` (Owner Only)
Creates new tokens and assigns them to the specified address.

**Parameters:**
- `to`: Address to receive minted tokens
- `amount`: Amount of tokens to mint

**Reverts:**
- `UnauthorizedAccess`: If caller is not owner
- `InvalidAddress`: If `to` is zero address
- `MaxSupplyExceeded`: If minting would exceed max supply

#### `burn(uint256 amount)`
Destroys tokens from caller's balance.

**Parameters:**
- `amount`: Amount of tokens to burn

**Reverts:**
- `InsufficientBalance`: If caller has insufficient balance

#### `burnFrom(address account, uint256 amount)`
Destroys tokens from specified account using allowance.

**Parameters:**
- `account`: Address to burn tokens from
- `amount`: Amount of tokens to burn

**Reverts:**
- `InvalidAddress`: If `account` is zero address
- `InsufficientBalance`: If account has insufficient balance
- `InsufficientAllowance`: If caller has insufficient allowance

#### `transferOwnership(address newOwner)` (Owner Only)
Transfers ownership to a new address.

**Parameters:**
- `newOwner`: Address of the new owner

**Reverts:**
- `UnauthorizedAccess`: If caller is not owner
- `InvalidAddress`: If `newOwner` is zero address

#### `renounceOwnership()` (Owner Only)
Permanently removes ownership, making administrative functions unusable.

**Reverts:**
- `UnauthorizedAccess`: If caller is not owner

## Events

### `Transfer(address indexed from, address indexed to, uint256 value)`
Emitted when tokens are transferred, including minting (from zero address) and burning (to zero address).

### `Approval(address indexed owner, address indexed spender, uint256 value)`
Emitted when allowance is set via approve function.

### `OwnershipTransferred(address indexed previousOwner, address indexed newOwner)`
Emitted when contract ownership is transferred or renounced.

## Custom Errors

### `InsufficientBalance(uint256 available, uint256 required)`
Thrown when attempting to transfer or burn more tokens than available.

### `InsufficientAllowance(uint256 available, uint256 required)`
Thrown when attempting to spend more than the approved allowance.

### `UnauthorizedAccess(address caller, address required)`
Thrown when non-owner attempts to call owner-only functions.

### `InvalidAddress(address provided)`
Thrown when zero address is provided where a valid address is required.

### `ZeroAmount()`
Thrown when zero amount is provided where a positive amount is expected.

### `MaxSupplyExceeded(uint256 currentSupply, uint256 maxSupply)`
Thrown when minting would exceed the maximum supply limit.

## Usage Examples

### Basic Token Operations

```solidity
// Transfer tokens
token.transfer(recipient, 1000 * 10**18); // Transfer 1000 CGX

// Approve spending
token.approve(spender, 5000 * 10**18); // Approve 5000 CGX

// Transfer from allowance
token.transferFrom(owner, recipient, 2000 * 10**18); // Transfer 2000 CGX

// Check balance
uint256 balance = token.balanceOf(account);

// Check allowance
uint256 allowance = token.allowance(owner, spender);
```

### Administrative Operations

```solidity
// Mint new tokens (owner only)
token.mint(recipient, 10000 * 10**18); // Mint 10000 CGX

// Burn tokens
token.burn(1000 * 10**18); // Burn 1000 CGX from caller

// Burn from allowance
token.burnFrom(account, 500 * 10**18); // Burn 500 CGX from account

// Transfer ownership
token.transferOwnership(newOwner);

// Renounce ownership (permanent)
token.renounceOwnership();
```

## Deployment

### Using Foundry

```bash
# Deploy with default parameters
forge script script/Deploy.s.sol:DeployToken --rpc-url <RPC_URL> --broadcast

# Deploy with custom parameters
TOKEN_NAME="My Token" TOKEN_SYMBOL="MTK" INITIAL_SUPPLY=2000000000000000000000000 forge script script/Deploy.s.sol:DeployToken --rpc-url <RPC_URL> --broadcast
```

### Environment Variables

- `TOKEN_NAME`: Token name (default: "Cognix Token")
- `TOKEN_SYMBOL`: Token symbol (default: "CGX")
- `INITIAL_SUPPLY`: Initial token supply in wei (default: 1,000,000 * 10^18)
- `TOKEN_OWNER`: Initial owner address (default: deployer)

## Security Considerations

1. **Owner Privileges**: The owner can mint tokens up to the max supply. Consider using a multisig wallet for the owner address.

2. **Max Supply**: The contract enforces a maximum supply of 1 billion tokens to prevent unlimited inflation.

3. **Ownership Renunciation**: Once ownership is renounced, no new tokens can be minted. This action is irreversible.

4. **Allowance Management**: Be cautious with large allowances. Consider using incremental approvals for better security.

5. **Zero Address**: The contract prevents transfers to/from zero address to avoid token loss.

## Testing

The contract includes comprehensive test coverage:

- Unit tests for all functions
- Edge case testing
- Access control validation
- Event emission verification
- Error condition testing

Run tests with:
```bash
forge test
```

## License

This contract is released under the MIT License.