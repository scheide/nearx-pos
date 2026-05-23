# Lab 2PC Foundry

This project implements a distributed two-phase commit (2PC) simulation with an Ethereum Sepolia smart contract audit log. The coordinator sends prepare messages to Bank A and Bank B, gathers their YES/NO votes, decides COMMIT or ABORT, and records the final decision in `CommitLog.sol`.

## Architecture

- Client triggers a transfer request
- Coordinator runs the 2PC protocol
- Bank A and Bank B vote on the transaction
- Final decision is stored in a Sepolia smart contract as an immutable audit record

## Project structure

- `src/CommitLog.sol` — smart contract storing transaction decisions
- `script/DeployCommitLog.s.sol` — Foundry deployment script
- `coordinator.js` — 2PC coordinator logic
- `bankA.js`, `bankB.js` — participant simulation scripts
- `foundry.toml` — Foundry configuration
- `.env` — Sepolia RPC and private key settings

## Setup

Install dependencies:

```bash
npm install
```

Build the contract:

```bash
forge build
```

## Sepolia configuration

Create a `.env` file with:

```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=YOUR_PRIVATE_KEY_WITH_0x
CONTRACT_ADDRESS=
```

## Deploy the contract

Run the Foundry deploy script and copy the contract address:

```bash
forge script script/DeployCommitLog.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

Update `.env` with the deployed address:

```env
CONTRACT_ADDRESS=0x...
```

## Run the simulation

Start the two bank participants in separate terminals:

Terminal 1:
```bash
node bankA.js
```

Terminal 2:
```bash
node bankB.js
```

Then run the coordinator to perform the 2PC transaction and record the decision on Sepolia:

Terminal 3:
```bash
node coordinator.js
```

## Quick verification

- `bankA.js` listens on port `5001`
- `bankB.js` listens on port `5002`
- `coordinator.js` sends `PREPARE`, collects votes, sends `COMMIT` or `ABORT`, and writes the decision to `CommitLog.sol`

## Notes

The blockchain is used here as an audit trail, not to replace the 2PC protocol itself. It provides an immutable record that the distributed transaction was finalized as COMMIT or ABORT.
