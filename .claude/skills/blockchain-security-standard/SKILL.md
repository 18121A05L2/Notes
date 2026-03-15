---
name: blockchain-security-standard
description: Mandatory security standards for all blockchain projects.
---
# Blockchain Security Standard (Enterprise Managed)

This skill is enforced organization-wide. All audited contracts must comply with these rules:

## Mandatory Controls
- **Reentrancy**: Must use `ReentrancyGuard` or CEI for all state-changing functions.
- **Access Control**: Critical functions must use `onlyOwner` or `AccessControl`.
- **Visibility**: Explicitly define visibility for all functions; avoid `public` for internal-only logic.
- **Oracle Safety**: Use heartbeat checks and price deviation limits for Chainlink Oracles.
- **Math**: Use `SafeMath` or Solidity 0.8+ for all arithmetic operations.

## Prohibited Patterns
- Never use `tx.origin` for authorization.
- Avoid low-level `call` without checking return values.
- No `selfdestruct` usage without multi-sig approval.
