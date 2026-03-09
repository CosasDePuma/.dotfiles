# Common EVM Vulnerabilities

Use this reference to identify and verify common attack vectors during audits.

## 1. Reentrancy
- **Cross-Contract Reentrancy:** When an external call leads back to the same contract or a related one before state is updated.
- **ERC721/1155 Callbacks:** `_safeMint` and `_safeTransferFrom` trigger `onERC721Received`, which can be exploited for reentrancy.
- **Checks-Effects-Interactions (CEI):** Always check if state is updated *before* the external call.

## 2. Vaults & Math (ERC4626)
- **Inflation Attack:** First depositor can manipulate the exchange rate by donating tokens to the vault.
- **Rounding Errors:** Rounding down in `deposit`/`mint` or rounding up in `withdraw`/`redeem` can lead to theft of dust or larger amounts over time.
- **Math Overflow/Underflow:** If Solidity <0.8.0 and `SafeMath` is not used.

## 3. Access Control & Initialization
- **Unprotected Initializers:** Proxy contracts must have their `initialize` functions called; if left open, an attacker can take ownership.
- **Centralisation:** Excessive power in `onlyOwner` roles (e.g., ability to drain funds or change critical parameters without a timelock).
- **Missing Modifiers:** Functions that should be restricted but lack access control modifiers.

## 4. Oracle & Price Manipulation
- **Spot Price Dependence:** Using `balanceOf` or `price` from a single DEX pool (Uniswap/Sushi) which can be manipulated via flash loans.
- **Stale Prices:** Using Chainlink or other oracles without checking for `updatedAt` timestamps.

## 5. Token Integrations
- **Fee-on-Transfer:** Tokens like `USDT` (if fee is enabled) or others that take a cut on transfer can break accounting logic.
- **Rebasing Tokens:** Tokens where the balance changes automatically (e.g., `stETH` in some modes, `Ampleforth`).
- **ERC20 `approve` race condition:** Old `approve` vs `increaseAllowance`.

## 6. Logic & State Management
- **Inconsistent Accounting:** `totalAssets()` vs internal mapping of balances.
- **Insecure Randomness:** Using `block.timestamp`, `block.number`, or `blockhash` for critical logic (e.g., gambling, selection).
- **Unbounded Loops:** Gas limit exhaustion when loops iterate over dynamic arrays (e.g., list of users).
