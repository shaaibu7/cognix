#!/bin/bash

# --- Deployment Script for Base (Etherscan V2 Verification) ---
# Adjusted for Cognix Marketplace structure

# Check if environment variables are set
if [ -z "$RPC_URL" ]; then
    echo "❌ Error: RPC_URL is not set."
    echo "   Please run: export RPC_URL=your_rpc_url"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY is not set."
    echo "   Please run: export PRIVATE_KEY=your_private_key"
    exit 1
fi

# Determine if we should verify
VERIFY_FLAG=""
if [ -n "$ETHERSCAN_API_KEY" ]; then
    echo "✅ Etherscan API Key found. Verification enabled (V2)."
    # Base Mainnet Chain ID: 8453
    # Base Sepolia Chain ID: 84532
    # We use the V2 API URL pattern
    VERIFY_FLAG="--verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --verifier-url https://api.etherscan.io/v2/api?chainid=8453"
else
    echo "⚠️  No ETHERSCAN_API_KEY found. Skipping verification."
fi

echo "🚀 Starting deployment to Base..."
echo "ℹ️  RPC URL: ${RPC_URL:0:20}..."
echo "ℹ️  Verifier URL: https://api.etherscan.io/v2/api?chainid=8453"
echo "ℹ️  Note: '--via-ir' is enabled. This makes compilation SLOW."

# Execute deployment from root
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url "$RPC_URL" \
  --broadcast \
  $VERIFY_FLAG \
  -vvvv \
  --via-ir \
  --private-key "$PRIVATE_KEY"

echo "✨ Deployment process finished."
