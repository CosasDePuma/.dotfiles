# Expert Audit Methodology & Checklists

Use this reference to ensure no subtle logical or mathematical vulnerabilities are missed during the audit process.

## 1. Mathematical Invariants & Rounding
- **Asymmetric Rounding in Subtraction:** When calculating a delta or area (e.g., `A - B`), always verify the rounding direction of each term. If the goal is a "conservative" result for the protocol:
  - The positive term (`A`) should round **DOWN**.
  - The negative/subtracted term (`B`) should round **UP**.
  - *Failure to do this leads to overpayments or protocol insolvency.*
- **Preview vs. Execution Consistency:** Ensure `view` functions (previews) use the exact same rounding logic as the state-changing functions. Discrepancies allow for arbitrage.

## 2. Integration & Multi-Step Flows
- **Fee Staleness & Slippage:** In flows that combine multiple protocols (e.g., Swap then Bridge), verify that fees quoted at the start remain valid regardless of the swap output. 
  - *Risk:* If fees scale with amount, a positive slippage (better price) might cause the second step to revert due to insufficient fees.
- **External Call Sequencing:** Analyze the order of operations when calling external routers. Ensure `msg.value` is handled correctly in all execution paths, especially the "excess refund" path.

## 3. Cryptography & Assembly
- **Memory Alignment in Assembly:** When using `mload` to extract data from `calldata` or `bytes`, remember that it reads 32 bytes. Always use bit-shifting (`shr`/`shl`) to clean adjacent "garbage" data from the word.
- **Signature Malleability:** Verify that `ecrecover` or `ECDSA.recover` wrappers enforce the 'low-s' value to prevent replay attacks via signature mutation (EIP-2098).

## 4. Verification Methodology
- **Invariant vs. Implementation:** Cross-reference the "Main Invariants" in the documentation with the code. If an invariant is violated, it's a High/Critical bug unless explicitly marked as "Intentional" in the scope.
- **Focus Areas:** Prioritize files and line ranges marked as "Differential Changes" or "Focus Areas" in the audit contest details. These are higher risk for regressions.
- **Slither Call-Graphs:** Use call-graphs to find unprotected execution paths in Account Abstraction (ERC-4337) wallets that might bypass the `EntryPoint`.
