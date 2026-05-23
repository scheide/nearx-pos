# Lab 2PC Foundry

This repository contains the Foundry-based implementation for the final distributed systems lab, focusing on two-phase commit (2PC) behavior and smart contract coordination. The project includes Solidity contracts, Foundry tests, and helper scripts to model and verify the commit protocol in a local Ethereum-like environment.

## Project structure

- `src/` — Solidity contracts for 2PC and coordination logic
- `test/` — Foundry test cases that validate commit/abort flows
- `script/` — deployment and interaction scripts

## Quick start

```bash
forge build
forge test
```

## Notes

Use `anvil` for a local node and `cast` for manual contract interaction when needed.
