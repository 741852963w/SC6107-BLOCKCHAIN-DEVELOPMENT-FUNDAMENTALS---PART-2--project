# Architecture

## Overview
This project implements SC6107 Option 4 (On-Chain Verifiable Random Game Platform) with two games:
- `RaffleGame`
- `DiceGame`

Core contracts:
- `GameTreasury`: centralized fund management and payouts
- `VRFManager`: randomness request/callback routing and request bookkeeping
- `RaffleGame`: raffle entry and winner selection
- `DiceGame`: bet creation and result settlement

## Contract Interaction
1. User calls game contract (`RaffleGame` or `DiceGame`).
2. Game contract requests randomness via `VRFManager`.
3. `VRFManager` receives callback from coordinator and dispatches result.
4. Game computes final outcome and calls `GameTreasury` for payout.

## Frontend Interaction
Frontend pages are under `frontend/app`:
- `/` dashboard
- `/raffle` raffle route
- `/dice` dice route

These routes are aligned with demo storytelling and map directly to on-chain game modules.
