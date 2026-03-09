# Common Cosmos & Go Vulnerabilities

## 1. Non-Deterministic State (Chain Halts)
- **Map Iteration:** Iterating over a `map` and updating state based on that order.
- **Floating Point Math:** Using `float64` for rewards or ratios instead of `sdk.Dec`.
- **External State:** Reading files, environment variables, or system time inside a handler.
- **Panic in ABCI Hooks:** Explicit `panic()` or unhandled runtime errors in `BeginBlocker` or `EndBlocker`. Unlike transactions, the SDK does not recover from these, causing a total chain halt.

## 2. Denial of Service (DoS)
- **Panic in Handler:** Triggering a `panic()` via malicious input (e.g., divide by zero, nil pointer) that isn't caught by the SDK's recovery middleware.
- **Gas Exhaustion:** Creating many small entries in the KVStore to make `Iterator` operations extremely expensive.
- **Resource Exhaustion:** Allocating large slices or maps based on user-provided length fields without validation.
- **Fragile Infrastructure Dependency:** Hard dependency on external modules or oracles (e.g., Pyth) where a `nil` or error return blocks all subsequent module logic (e.g., halting all bridge withdrawals).

## 3. Financial & Logic Errors
- **Oracle Staleness:** Failing to check the timestamp of oracle data, allowing users to transact against outdated prices during high volatility.
- **Integer Overflow:** Although Go 1.x doesn't revert on overflow, `sdk.Int` and `sdk.Uint` (wrappers for `big.Int`) are safe, but raw `uint64` can overflow.
- **Rounding in Rewards:** Always rounding in favor of the protocol (usually rounding down for payouts).
- **Missing Asset Burn:** When "unstaking" or "withdrawing", failing to burn the representation tokens or update the supply.
- **Nonce/Event Consumption on Failure:** Marking an event as "processed" (consuming a nonce) before the full financial logic has successfully committed, leading to permanent fund loss.

## 4. IBC Risks
- **Packet Spoofing:** Failing to verify the source channel or port in a `MsgRecvPacket`.
- **Double Spending:** Flaws in the escrow logic during cross-chain transfers.
- **Timed Out Packets:** Improper handling of `OnTimeoutPacket` which could leave funds locked in escrow forever.
