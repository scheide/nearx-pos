# Predict The Future - Smart Contract Security Challenge

A security challenge demonstrating critical vulnerabilities in blockchain randomness and how to exploit and fix them. This project is part of the NEARx POS course on Smart Contract Security.

## 📋 Overview

This project contains a vulnerable smart contract (`PredictTheFutureChallenge`) that implements a prediction game where users attempt to guess a random number (0-9). The contract has critical security flaws that allow an attacker to predict the outcome and drain all funds with near certainty.

## 🎯 Learning Objectives

- Understand the dangers of using predictable randomness in smart contracts
- Learn how blockchain data (blockhash, timestamp) can be exploited
- Practice identifying and exploiting vulnerabilities
- Implement secure solutions (commit-reveal scheme)

## 📁 Project Structure

```
contracts/
├── PredictTheFuture.sol           # Vulnerable contract (original)
├── PredictTheFutureExploit.t.sol  # Proof-of-concept exploit
└── PredictTheFutureFixed.sol      # Secure implementation

documentation/
├── SECURITY_AUDIT.md              # Comprehensive security audit
├── SECURITY_ISSUES_EXPLAINED.md   # Detailed vulnerability explanations
├── EXPLOIT_FLOW_DIAGRAM.md        # Visual exploit flow
└── AUDIT_SUMMARY.md               # Executive summary
```

## 🔴 Critical Vulnerabilities

### 1. Predictable Randomness (CRITICAL)
The contract uses `blockhash(block.number - 1)` and `block.timestamp` to generate random numbers. Once blocks are mined, these values are publicly known, allowing attackers to calculate the answer before calling `settle()`.

**Impact:** Contract can be drained with ~100% probability

### 2. State Reset Without Payment Verification (HIGH)
The `guesser` is reset even when the guess is wrong, allowing unlimited retry attempts without additional payment.

**Impact:** Enables exploitation combined with predictable randomness

### 3. Block Timestamp Manipulation (MEDIUM)
Miners can manipulate `block.timestamp` within ±15 seconds.

## 🛠️ Setup & Installation

### Prerequisites
- Node.js (v18+)
- npm or yarn

### Install Dependencies

```bash
npm install
```

## 🧪 Running Tests

### Run All Tests

```bash
npx hardhat test
```

### Run Solidity Tests Only

```bash
npx hardhat test solidity
```

### Run the Exploit

The exploit test demonstrates how an attacker can drain the contract:

```bash
npx hardhat test --grep "Exploit"
```

## 📖 How It Works

### Game Flow (Vulnerable Contract)

1. **Deploy**: Contract is funded with 1 ETH by the deployer
2. **Lock Guess**: User deposits 1 ETH and locks in a guess (0-9)
3. **Wait**: Must wait for `settlementBlockNumber` to pass
4. **Settle**: Calculate answer and check if guess matches
   - **Win**: User receives 2 ETH (2x return)
   - **Lose**: User loses 1 ETH (stays in contract)

### The Vulnerability

The answer is calculated as:
```solidity
uint8 answer = uint8(uint256(keccak256(abi.encodePacked(
    blockhash(block.number - 1), 
    block.timestamp
))) % 10);
```

**Problem:** Both `blockhash(block.number - 1)` and `block.timestamp` are known/predictable when `settle()` is called, allowing attackers to:
- Calculate the answer before calling `settle()`
- Only call `settle()` when they know they'll win
- Retry indefinitely (since state resets on wrong guesses)

## 🔓 Exploit Demonstration

See `contracts/PredictTheFutureExploit.t.sol` for a complete exploit that:
1. Locks in a guess
2. Waits for settlement block
3. Calculates the answer using known block data
4. Only calls `settle()` when the guess matches the answer
5. Repeats until successful

## ✅ Secure Solution

The fixed contract (`PredictTheFutureFixed.sol`) implements a **commit-reveal scheme**:
1. **Commit Phase**: Users commit to a hash of their guess + secret
2. **Reveal Phase**: Users reveal their guess and secret after blocks have passed
3. **Settlement Phase**: Answer is calculated from future block data that didn't exist at commitment time

This ensures users cannot predict the answer when they commit their guess.

## 📚 Documentation

- **[SECURITY_AUDIT.md](./SECURITY_AUDIT.md)** - Complete security audit report
- **[SECURITY_ISSUES_EXPLAINED.md](./SECURITY_ISSUES_EXPLAINED.md)** - Detailed explanations of each vulnerability
- **[EXPLOIT_FLOW_DIAGRAM.md](./EXPLOIT_FLOW_DIAGRAM.md)** - Visual representation of the exploit
- **[AUDIT_SUMMARY.md](./AUDIT_SUMMARY.md)** - Executive summary

## 🚀 Deployment

### Deploy to Sepolia Testnet

1. Set your private key:
   ```bash
   npx hardhat keystore set SEPOLIA_PRIVATE_KEY
   ```

2. Set your RPC URL:
   ```bash
   npx hardhat keystore set SEPOLIA_RPC_URL
   ```

3. Deploy:
   ```bash
   npx hardhat ignition deploy --network sepolia ignition/modules/Counter.ts
   ```

## ⚠️ Warning

**DO NOT deploy the vulnerable contract (`PredictTheFuture.sol`) to mainnet.** It will be immediately exploited and all funds will be stolen.

## 📝 License

ISC

## 🙏 Acknowledgments

Part of the NEARx POS course on Smart Contract Security. Built with [Hardhat](https://hardhat.org/) and [Foundry](https://book.getfoundry.sh/).
