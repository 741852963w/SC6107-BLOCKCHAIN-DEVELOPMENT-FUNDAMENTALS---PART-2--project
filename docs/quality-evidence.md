# Quality Evidence Bundle

## Required Commands (SC6107)
```bash
forge test -vv
forge coverage
forge snapshot
slither .
```

## Execution Attempt in Current Environment
Timestamp: 2026-05-13 (local shell session)

Observed results:
- `forge` command not found
- `slither` command not found

This repository now includes all required evidence command definitions, but the current machine shell does not have the toolchain installed.

## Evidence Files Prepared
- `docs/test-report.md`
- `docs/gas-optimization.md`
- `docs/security-analysis.md`
- `docs/deployment-guide.md`

## What to Run on a Foundry-enabled Machine Before Final Submission
1. Run `forge test -vv` and paste summary into `docs/test-report.md`.
2. Run `forge coverage` and record line coverage percentage in `docs/test-report.md`.
3. Run `forge snapshot` and commit `.gas-snapshot`; summarize in `docs/gas-optimization.md`.
4. Run `slither .` and append critical findings + mitigations in `docs/security-analysis.md`.

## Existing Scope Evidence from Repository Structure
- Unit tests:
  - `test/unit/RaffleGameTest.t.sol`
  - `test/unit/DiceGameTest.t.sol`
  - `test/unit/RaffleTest.t.sol`
- Staging/integration-style test:
  - `test/staging/RaffleStagingTest.t.sol`
