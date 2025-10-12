# Hanatucoin (HANA) 🌸

A Stacks SIP-010 compliant fungible token smart contract implementing Hanatucoin (HANA), featuring comprehensive token management capabilities including minting, burning, pausable transfers, and batch operations.

## 🚀 Features

- **SIP-010 Compliant**: Fully implements the Stacks Improvement Proposal 010 for fungible tokens
- **Mintable**: Authorized minters can create new tokens up to the maximum supply
- **Burnable**: Token holders can burn their own tokens
- **Pausable**: Contract owner can pause/unpause all token transfers
- **Access Control**: Role-based permissions for minting and administrative functions  
- **Batch Operations**: Support for batch transfers (useful for airdrops)
- **Maximum Supply Cap**: Hard limit of 1 billion HANA tokens
- **Decimal Support**: 6 decimal places for precise fractional amounts

## 📊 Token Details

- **Name**: Hanatucoin
- **Symbol**: HANA
- **Decimals**: 6
- **Maximum Supply**: 1,000,000,000 HANA (1 billion)
- **Initial Supply**: 100,000,000 HANA (100 million) minted to contract deployer
- **Token URI**: https://hanatucoin.com/metadata

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

- [Clarinet](https://docs.hiro.so/clarinet) (v3.0+)
- [Node.js](https://nodejs.org/) (v16+)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installing Clarinet

```bash
# Using Homebrew (macOS)
brew install clarinet

# Using cargo (cross-platform)
cargo install clarinet-cli

# Or download from GitHub releases
# https://github.com/hirosystems/clarinet/releases
```

## 🏗️ Project Setup

1. **Clone the repository**:
```bash
git clone https://github.com/your-username/hanatucoin.git
cd hanatucoin
```

2. **Install dependencies**:
```bash
npm install
```

3. **Check contract syntax**:
```bash
clarinet check
```

4. **Run tests**:
```bash
npm test
```

## 🧪 Testing

### Running Unit Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test hanatucoin.test.ts
```

### Manual Testing with Clarinet Console

```bash
# Start Clarinet console
clarinet console
```

In the console, you can interact with the contract:

```clarity
;; Get token information
(contract-call? .hanatucoin get-name)
(contract-call? .hanatucoin get-symbol)
(contract-call? .hanatucoin get-decimals)
(contract-call? .hanatucoin get-total-supply)

;; Check balance
(contract-call? .hanatucoin get-balance 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Transfer tokens (as contract owner)
(contract-call? .hanatucoin transfer u1000000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 none)
```

## 📋 Contract Functions

### SIP-010 Standard Functions

| Function | Type | Description |
|----------|------|-------------|
| `transfer` | Public | Transfer tokens between principals |
| `get-name` | Read-only | Returns token name |
| `get-symbol` | Read-only | Returns token symbol |
| `get-decimals` | Read-only | Returns number of decimals |
| `get-balance` | Read-only | Returns balance of a principal |
| `get-total-supply` | Read-only | Returns current total supply |
| `get-token-uri` | Read-only | Returns token metadata URI |

### Administrative Functions

| Function | Type | Description |
|----------|------|-------------|
| `set-contract-owner` | Public | Transfer contract ownership |
| `get-contract-owner` | Read-only | Get current contract owner |
| `set-paused` | Public | Pause/unpause contract |
| `is-paused` | Read-only | Check if contract is paused |

### Minting Functions

| Function | Type | Description |
|----------|------|-------------|
| `set-minter` | Public | Authorize/deauthorize minters |
| `is-minter` | Read-only | Check if principal is authorized minter |
| `mint` | Public | Mint new tokens (owner/minters only) |
| `burn` | Public | Burn own tokens |

### Utility Functions

| Function | Type | Description |
|----------|------|-------------|
| `get-max-supply` | Read-only | Returns maximum token supply |
| `would-exceed-max-supply` | Read-only | Check if amount would exceed max supply |
| `batch-transfer` | Public | Transfer tokens to multiple recipients |

## 🔒 Security Features

### Access Control
- **Contract Owner**: Can set new owner, pause contract, authorize minters
- **Authorized Minters**: Can mint new tokens up to max supply
- **Token Holders**: Can transfer and burn their own tokens

### Error Handling
The contract includes comprehensive error codes:

```clarity
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-transfer-failed (err u103))
(define-constant err-mint-failed (err u104))
(define-constant err-burn-failed (err u105))
(define-constant err-invalid-amount (err u106))
(define-constant err-invalid-recipient (err u107))
```

### Pausable Contract
The contract owner can pause all token operations in case of emergencies:

```clarity
;; Pause the contract
(contract-call? .hanatucoin set-paused true)

;; Resume operations
(contract-call? .hanatucoin set-paused false)
```

## 🚀 Deployment

### Local Deployment (Devnet)

```bash
# Deploy to local devnet
clarinet deployment apply --devnet
```

### Testnet Deployment

1. **Configure your deployment**:
   Edit `settings/Testnet.toml` with your deployment parameters.

2. **Deploy to testnet**:
```bash
clarinet deployment apply --testnet
```

### Mainnet Deployment

1. **Configure mainnet settings**:
   Edit `settings/Mainnet.toml` with your production parameters.

2. **Deploy to mainnet**:
```bash
clarinet deployment apply --mainnet
```

⚠️ **Warning**: Mainnet deployments are permanent and irreversible. Test thoroughly on devnet and testnet first.

## 📖 Usage Examples

### Basic Token Operations

```typescript
// Transfer tokens
const transferTx = await openContractCall({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'hanatucoin',
  functionName: 'transfer',
  functionArgs: [
    uintCV(1000000), // 1 HANA (with 6 decimals)
    principalCV('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'),
    principalCV('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'),
    noneCV()
  ]
});
```

### Administrative Operations

```typescript
// Authorize a minter
const authorizeMinterTx = await openContractCall({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'hanatucoin',
  functionName: 'set-minter',
  functionArgs: [
    principalCV('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'),
    trueCV()
  ]
});
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Run tests**: `npm test`
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for any API changes
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Stacks Foundation](https://stacks.org/) for the Stacks blockchain
- [Hiro](https://hiro.so/) for Clarinet and development tools
- [SIP-010](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md) for the fungible token standard

## 📞 Support

For support and questions:

- 📧 Email: support@hanatucoin.com
- 🐦 Twitter: [@hanatucoin](https://twitter.com/hanatucoin)
- 💬 Discord: [Hanatucoin Community](https://discord.gg/hanatucoin)
- 📖 Documentation: [docs.hanatucoin.com](https://docs.hanatucoin.com)

---

**⚠️ Disclaimer**: This is experimental software. Use at your own risk. Always audit smart contracts before using them with real value on mainnet.
 
