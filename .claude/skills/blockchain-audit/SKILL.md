---
name: blockchain-audit
description: Specialized instructions for auditing Solidity smart contracts.
---
# Blockchain Audit Skill

This skill provides a framework for deep-dive security analysis of EVM-based smart contracts.

## 🛡️ Core Audit Focus
Refer to the references for specific implementation patterns:
1.  **Reentrancy**: Validate CEI pattern and check for nonReentrant modifiers.
2.  **Access Control**: Verify `OnlyOwner` and `RBAC` logic.
3.  **Low-Level Safety**: Inspect `delegatecall`, `call`, and `selfdestruct`.

## 📂 Supporting Data
- Read [react_patterns.md](references/common_vulnerabilities.md) for a list of known attack vectors.
- Use [audit_helper.py](scripts/audit_helper.py) to scan for simple patterns.

## ✅ Checklists
- [ ] Check for `tx.origin` usage.
- [ ] Verify `selfdestruct` constraints.
- [ ] Inspect storage collisions in proxy patterns.
