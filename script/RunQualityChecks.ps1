$ErrorActionPreference = "Stop"

Write-Host "Running SC6107 quality checks..."

forge test -vv
forge coverage
forge snapshot
slither .

Write-Host "Quality checks completed."
