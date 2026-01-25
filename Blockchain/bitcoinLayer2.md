Different types of Bitcoin L2s use different methods.

1. State channels (e.g., Lightning Network) let two users lock up Bitcoin and exchange as many transactions as they want instantly, with only the final balance recorded on-chain.

2. Sidechains (e.g., Stacks and Rootstock) act as independent blockchains pegged to Bitcoin, often adding smart contract support.

3. Rollups (e.g., Merlin) gather thousands of transactions, generate cryptographic proofs, and submit a single summary back to Bitcoin, making the process faster, cheaper, and more scalable.

| Chain           | L2 Type        | Design            | Fee / Tx (₹)   | Native Token | Languages | Security (/10) | Finality    | Age    | Certificate Fit | TVL (Approx)      | Daily Volume (Approx) |
| --------------- | -------------- | ----------------- | -------------- | ------------ | --------- | -------------- | ----------- | ------ | --------------- | ----------------- | --------------------- |
| Lightning       | State Channel  | HTLC              | 0.05 - 0.50    | BTC          | Go, Rust  | 9.5            | Instant     | 7y 9m  | No              | ~$0.30B           | ~$20M – $40M          |
| Ark Protocol    | Off-chain L2   | Virtual UTXO      | 0.50 - 3.00    | BTC          | Rust      | 8.5            | BTC-settled | ~2m    | No              | ~$0 (not tracked) | ~$0 (early)           |
| RGB             | Client-side L2 | Client validation | 0.50 - 2.00    | BTC          | Rust      | 9.0            | BTC-anchor  | 2y 8m  | Partial         | ~$0 (not tracked) | ~$0 (off-chain)       |
| Merlin Chain    | Rollup         | ZK Rollup         | 1.00 - 5.00    | MERL         | Solidity  | 7.5            | 2-5s        | 1y 11m | Yes             | ~$0.16B           | ~$10M – $30M          |
| Bitlayer        | Rollup         | BitVM + ZK        | 1.00 - 4.00    | BTR          | Solidity  | 7.5            | 2-5s        | 1y 8m  | Yes             | ~$0.40B           | ~$5M – $20M           |
| B² Network      | Rollup         | ZK Rollup         | 1.00 - 4.50    | B²           | Solidity  | 7.5            | 2-5s        | 1y 8m  | Yes             | ~$0.37B           | ~$5M – $20M           |
| Citrea          | Rollup         | ZK + BTC DA       | 2.00 - 7.00    | BTC          | Solidity  | 8.0            | ~5s         | <2m    | Early           | ~$0 (testnet)     | ~$0                   |
| BEVM            | Rollup         | Taproot EVM       | 3.00 - 10.00   | BTC          | Solidity  | 7.5            | 5-10s       | 1y 9m  | Yes             | ~$0 (not indexed) | ~$0 (low activity)    |
| Core DAO        | Hybrid L2      | Satoshi Plus      | 3.00 - 10.00   | CORE         | Solidity  | 8.5            | 5-10s       | 2y 11m | Yes             | ~$0.67B           | ~$10M – $40M          |
| BOB             | Hybrid Rollup  | Optimistic        | 4.00 - 12.00   | BTC          | Solidity  | 8.0            | ~5s         | 1y 7m  | Yes             | ~$0.25B           | ~$5M – $15M           |
| BounceBit       | Rollup         | Optimistic        | 5.00 - 15.00   | BB           | Solidity  | 7.0            | ~5s         | 1y 7m  | Partial         | ~$0.06B           | ~$1M – $5M            |
| Mintlayer       | Sidechain      | UTXO              | 6.00 - 20.00   | ML           | Rust      | 7.5            | ~10s        | 1y 11m | Partial         | ~$0.05B           | ~$2M – $10M           |
| Stacks          | Bitcoin L1.5   | Nakamoto          | 15.00 - 50.00  | STX          | Clarity   | 8.0            | 10-15m      | 4y 11m | Partial         | ~$0.18B           | ~$10M – $25M          |
| Rootstock (RSK) | Sidechain      | Merge-mined       | 20.00 - 70.00  | rBTC         | Solidity  | 8.0            | ~30s        | 7y 11m | Yes             | ~$0.23B           | ~$5M – $15M           |
| Liquid          | Sidechain      | Federated         | 30.00 - 100.00 | L-BTC        | C++ / RPC | 7.0            | ~60s        | 7y 3m  | No              | ~$3.0B            | ~$2M – $8M            |


## RGB and ARk protocol ( Not Suitable)

- [100-200 rupees] :: The cost is only the Bitcoin network transaction fee for the anchoring transaction on L1. There's no extra RGB-specific fee

## Lightning Network using TapRoot ( Not Suitable)

- To start, you will need to pay roughly ₹1,500( 500 - 2000) in on-chain fees to set up your infrastructure (opening channels/minting). After that, sending individual certificates to users will cost you less than ₹1 per transaction - If we issue a single certificate or batch of certificates (using merkle root) it consts us that 1500 to 2000 - we dont have transfer features where we cant use lightning which is best for transfers , we just store data on the blockchain and verify - The issuance starts on Bitcoin Layer-1 for security, but sets up for Lightning transfers

# Overview of Merlin Chain ( Final Selected chain )

Merlin Chain is a Bitcoin Layer 2 (L2) solution that uses ZK-Rollups, a decentralized oracle network, and on-chain BTC fraud proofs. It's EVM-compatible, meaning you can deploy Solidity smart contracts on it just like on Ethereum or other EVM chains. This allows seamless use of Ethereum tools, EIPs, precompiles, and opcodes in a Bitcoin ecosystem. The native currency is BTC (wrapped or bridged forms), and it supports low fees with high scalability.

Official resources:

- Website: https://merlinchain.io/
- Docs: https://docs.merlinchain.io/merlin-docs
- Bridge: https://merlinchain.io/bridge (for mainnet) or https://testnet.merlinchain.io/bridge (for testnet)
- Discord: https://discord.gg/merlinchain (for community support and testnet faucet)

### Tools for Development and Deployment

Since Merlin is EVM-compatible, you can use standard Ethereum development tools. No special Merlin-specific tools are required beyond configuring the network settings (RPC and Chain ID). Recommended tools include:

- **Hardhat**: Popular for local development, testing, and deployment. It supports scripting deployments to custom networks like Merlin.
- **Remix IDE**: Web-based tool for writing, compiling, and deploying Solidity contracts directly from your browser. Connect it to Merlin via a wallet like MetaMask.
- **Foundry**: A fast, Rust-based alternative to Hardhat for testing and deploying contracts.
- **Truffle**: Another framework for development and deployment, though less common now.
- **OpenZeppelin Wizard**: For generating secure contract templates (e.g., ERC-20, ERC-721).
- **Wallets**: MetaMask (add Merlin network manually), UniSat (Bitcoin-native but supports EVM for Merlin), or any EVM-compatible wallet.
- **Block Explorers**: Use the official explorers for transaction tracking.
- **Other Resources**: Chainstack or BlockPI for enhanced RPC nodes (if the public ones are rate-limited). For advanced setups, check Merlin's GitHub repos like merlin-cdk-validium-contracts for core contracts.

For frontend integration (e.g., dApps), use libraries like ethers.js or web3.js to connect to the RPC endpoints below.

### Testnets Available

Yes, Merlin has a public testnet for development and testing.

- **Network Name**: Merlin Testnet
- **Chain ID**: 686868
- **Currency Symbol**: BTC (testnet version)
- **Block Explorer**: https://testnet-scan.merlinchain.io
- **Description**: A testing environment mirroring mainnet, ideal for deploying and interacting with contracts without real value at risk.

Mainnet details (for production):

- **Network Name**: Merlin Mainnet
- **Chain ID**: 4200
- **Currency Symbol**: BTC
- **Block Explorer**: https://scan.merlinchain.io

### RPC Endpoints

RPCs are used for interacting with the chain (e.g., querying data for your frontend via ethers.js/web3.js or deploying contracts). The public ones are rate-limited, so for heavy use, consider providers like Chainstack, BlockPI, or dRPC.

- **Testnet RPC**: https://testnet-rpc.merlinchain.io
- **Mainnet RPC**: https://rpc.merlinchain.io

### How to Get Faucet or Testnet Tokens

Testnet tokens (BTC) have no real value and are for testing only. Two main ways:

1. **Discord Faucet Bot**:

   - Join Discord: https://discord.gg/merlinchain.
   - Find the testnet faucet channel/bot.
   - Claim: Use the bot command (e.g., `/faucet address: yourAddress`).
   - Limits: Max 0.0001 test BTC per address, one claim per 24 hours.

2. **Bridge via Testnet Bridge**:
   - Go to https://testnet.merlinchain.io/bridge.
   - Connect your wallet (e.g., UniSat or MetaMask).
   - First, get BTC testnet assets from a Bitcoin testnet faucet (e.g., https://bitcoinfaucet.uo1.net/ or search for "Bitcoin testnet faucet").
   - Bridge them to Merlin Testnet:
     - Select BTC (or BRC-20 if needed).
     - Enter amount and transfer.
     - Sign and wait for confirmation (check status in history).
   - Note: The testnet vault has limited balance; if exceeded, bridging fails. Retry later.

For BRC-20 test tokens: Use the bridge's faucet popup to claim directly.

If you run into issues, check the Medium guide for visuals: https://medium.com/@merlinchaincrypto/merlin-chain-testnet-user-guide-6632f4a2ba6e.

# 📊 Estimated Write Functions (Gas / MERL / ₹)

## Assumptions (explicit & important)

- **Merlin avg gas price**: `0.15 Gwei`
- **Merlin token price**: `$0.382`
- **USD → INR**: `1 USD ≈ ₹83`
- **1 Gwei = 1e-9 MERLIN**

## Conversion Reference (used everywhere)

```
Gas Cost (MERLIN) = gasUsed × 0.15 × 10⁻⁹
Cost (USD)        = MERLIN × 0.382
Cost (INR)        = USD × 83
```

---

## 🧾 WRITE FUNCTIONS – TRANSACTION COST ESTIMATION

### 🔹 Single Certificate Operations

| Function                        | Estimated Gas | Gas (Gwei) | Cost (₹) |
| ------------------------------- | ------------- | ---------- | -------- |
| `issueCertificate`              | ~180,000      | 27,000     | ₹0.86    |
| `renewCertificate`              | ~210,000      | 31,500     | ₹1.00    |
| `reissueCertificate`            | ~170,000      | 25,500     | ₹0.81    |
| `reissueWithMetadata`           | ~200,000      | 30,000     | ₹0.95    |
| `updateSingleCertificateStatus` | ~70,000       | 10,500     | ₹0.33    |
| `updateCertificateMetadata`     | ~90,000       | 13,500     | ₹0.43    |

---

### 🔹 Batch Certificate Operations

| Function                         | Estimated Gas | Gas (Gwei) | Cost (₹) |
| -------------------------------- | ------------- | ---------- | -------- |
| `issueBatchOfCertificates`       | ~120,000      | 18,000     | ₹0.57    |
| `renewBatchOfCertificates`       | ~140,000      | 21,000     | ₹0.67    |
| `renewCertificateInBatch`        | ~110,000      | 16,500     | ₹0.52    |
| `updateBatchCertificateStatus`   | ~80,000       | 12,000     | ₹0.38    |
| `updateCertificateInBatchStatus` | ~60,000       | 9,000      | ₹0.29    |

---

### 🔹 Admin / Control Operations

| Function  | Estimated Gas | Gas (Gwei) | Cost (₹) |
| --------- | ------------- | ---------- | -------- |
| `pause`   | ~35,000       | 5,250      | ₹0.17    |
| `unpause` | ~35,000       | 5,250      | ₹0.17    |

# Other Considerations

-> 🥇 Best Low-Fee + EVM Compatibility :: Merlin Chain , Bitlayer and B² Network

-> 🥈 Next Tier — Low-fee but newer :: BEVM , Core DAO and BOB

-> 🥉 Mature but higher fees :: Rootstock (RSK)
