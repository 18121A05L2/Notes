---
description: Run a security audit checklist on a Solidity file
---
This workflow performs a standard security sweep of a smart contract file.

1. Read the specified Solidity file.
2. Search for common vulnerability patterns (tx.origin, delegatecall).
// turbo
3. Run a slither analysis on the project to catch automated issues.
4. Summarize the findings and provide a security report.
