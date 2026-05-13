# Provably Fair On-Chain GameHub (SC6107 Option 4)

This repository contains the SC6107 development project implementation for Option 4 (On-Chain Verifiable Random Game Platform).

## Project Scope
- Two game modules:
  - `RaffleGame` (`src/games/RaffleGame.sol`)
  - `DiceGame` (`src/games/DiceGame.sol`)
- Shared system contracts:
  - `GameTreasury` (`src/core/GameTreasury.sol`)
  - `VRFManager` (`src/core/VRFManager.sol`)
- Frontend routes:
  - `/` dashboard
  - `/raffle`
  - `/dice`

## Repository Structure
- `src/` Solidity contracts
- `test/` Foundry tests
- `script/` deployment scripts
- `frontend/` Next.js frontend
- `docs/` architecture, security, gas, deployment, and submission docs

## Quick Start

### Contracts (Foundry)
```bash
forge build
forge test
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Documentation
- `docs/architecture.md`
- `docs/security-analysis.md`
- `docs/gas-optimization.md`
- `docs/deployment-guide.md`
- `docs/user-guide.md`
- `docs/test-report.md`
- `docs/team-contribution.md`
- `docs/presentation-outline.md`

## Submission Deliverables Alignment
- Source code in GitHub repository
- Slide deck (PDF) for presentation
- Team contribution traceability through commit history
- Required peer evaluation completed by all members
