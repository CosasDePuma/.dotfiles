# Expert Cosmos & Go Audit Methodology

Use this reference to ensure deterministic state, gas efficiency, and secure message handling in Cosmos SDK projects.

## 1. Determinism & Consensus (Go-Specific)
- **Map Iteration:** Go maps are non-deterministic. NEVER iterate over maps in `BeginBlocker`, `EndBlocker`, or any code that affects the state (`AppHash`). Use sorted slices or the SDK's `Iterator` patterns.
- **Float Operations:** Avoid `float32/64` in consensus-critical math. Rounding differences across different architectures will cause chain halts. Use `sdk.Dec` or `sdk.Int`.
- **System Time:** Never use `time.Now()`. Use `ctx.BlockTime()` to ensure all nodes use the same timestamp.

## 2. Gas & DoS Prevention
- **Unbounded Loops:** Check for loops that iterate over data from the KVStore without a limit. An attacker can bloat the state to trigger a DoS (Out of Gas) for legitimate users.
- **Panic Recovery in ABCI:** Ensure all logic executed in `BeginBlocker` and `EndBlocker` is wrapped in `defer recover()` or returns errors instead of panicking. A panic here halts the entire chain.
- **Resource Deadlocks (Counters):** Audit logic that requires participant counters (e.g., `active_users`, `reward_managers`) to reach exactly zero before closing a pool or recovering funds. Verify if inactive users or "dust" balances can permanently lock protocol resources.

## 3. Oracle & External Data Integration
- **Price Component Consistency:** Check if different components (EMA vs Spot) are mixed. If EMA is used for health/LTV checks, verify that Spot is not used for execution/seizure without a strict divergence check (e.g., max 10% difference).
- **Price Staleness:** Always verify the timestamp/height of oracle data. Blindly using the "latest" stored price allows for bypasses during market volatility.
- **Availability Guardrails:** Check for `nil` or zero returns from oracles. If a critical path (like withdrawals) depends on an oracle, ensure a failure doesn't cause a permanent DoS.

## 4. Message Validation & Access Control
- **Economic Barrier Bypass:** Investigate if "entry barriers" (deposit thresholds, minimum staking) can be satisfied within a single transaction using flash loans or temporary liquidity, bypassing intended long-term commitment requirements.
- **`ValidateBasic()` Completeness:** Ensure that all input validation (address format, non-negative amounts, string lengths) is done in `ValidateBasic()` before reaching the `Keeper`.
- **Unauthorized Keeper Access:** Verify that `Keeper` methods check for appropriate permissions.

## 5. Arithmetic & Precision
- **Intermediate Overflow:** Check for intermediate products in fee/rebate calculations (e.g., `balance * bps / 10000`). For tokens with high precision (18 decimals), ensure these are performed using `sdk.Int` or `uint128` to prevent DoS.
- **Rounding Consistency:** Verify rounding directions. Protocol should generally round **UP** for debts/obligations and **DOWN** for payouts/rewards to ensure solvency.
- **Asymmetric Rounding in Multi-Step Flows:** When converting between tokens (e.g., `Asset -> Shares -> Asset`), ensure rounding errors do not allow for "free" share generation.

## 6. IBC & Cross-Chain Security
- **Acknowledgment Handlers:** Verify that failed IBC acknowledgments correctly roll back state changes.
- **Callback Reentrancy:** Check if IBC callbacks allow for re-entering the state before the current packet processing is finished.
