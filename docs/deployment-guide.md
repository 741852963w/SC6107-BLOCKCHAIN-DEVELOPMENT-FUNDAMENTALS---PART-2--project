# Deployment Guide

## Prerequisites
- Foundry installed (`forge`, `cast`, `anvil`)
- RPC endpoint (local or testnet)
- funded deployer key

## Local Deployment (recommended for demo)
1. Start local node:
```bash
anvil
```
2. Deploy core contracts:
```bash
forge script script/DeployCore.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```
3. Deploy game contracts and wire dependencies:
```bash
forge script script/DeployRaffle.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

## Frontend
```bash
cd frontend
npm install
npm run dev
```

## Acceptance Checklist
- Raffle entry transaction succeeds.
- Dice bet placement succeeds.
- Randomness callback path is executed.
- Winner/bet settlement and payout are observable.
