# Gas Optimization

## Approach
- Keep core game logic compact and modular.
- Centralize treasury operations in one contract to avoid duplicated payout logic.
- Use focused data flow in game settlement to reduce unnecessary storage writes.

## Measurement Commands
```bash
forge snapshot
```

## Expected Output Artifact
- `.gas-snapshot` at repository root

## Environment Note
- `forge` is not available in the current shell environment, so snapshot generation should be executed in a Foundry-enabled environment before final grading screenshot capture.

## Main Operations to Report
- Raffle entry
- Raffle settlement
- Dice bet placement
- Dice settlement
- Treasury payout
