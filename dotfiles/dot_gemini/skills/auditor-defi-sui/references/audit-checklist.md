# Expert Sui & Move Audit Methodology

## Phase 1: Research (The "Sui Architect" Mindset)
1. **Module & Struct Discovery:** 
   - Identify all modules (`module package::module_name`).
   - List all structs with `has key, store` (objects).
   - Identify "Shared" vs. "Owned" objects.
2. **Entry Function Mapping:**
   - Map all `entry fun` and `public entry fun`.
   - Identify which functions require specific `Capability` objects or address checks.
3. **Dependency Analysis:**
   - Check `Move.toml` for external dependencies.
   - Trace calls to standard Sui libraries (`sui::tx_context`, `sui::coin`, `sui::clock`).
4. **Project Setup:**
   - Run `sui move build` and `sui move test`.
   - Ensure the environment is correctly configured with `sui` CLI.

## Phase 2: Investigation (The "Move Researcher" Mindset)
1. **Access Control Audit:**
   - Verify every administrative action is protected by a `Capability` object.
   - Check if capabilities can be "leaked" via incorrect `store` abilities.
2. **Object Safety Audit:**
   - Check for "Arbitrary Object Ingestion" in functions that accept objects as parameters.
   - Verify `object::id` is used for identity checks instead of `uid_to_address`.
   - Trace object lifecycle (creation, transfer, freezing, deletion).
3. **PTB & Atomicity Audit:**
   - Look for logic that assumes multiple steps in a PTB are independent.
   - Audit flash loan logic for "reentrancy-like" patterns within a PTB.
4. **Coin & Balance Audit:**
   - Ensure `Coin` and `Balance` objects are handled correctly (merging, splitting).
   - Verify decimal calculations and precision for SUI and custom tokens.
5. **Arithmetic Audit:**
   - Check all arithmetic for potential overflow/underflow.
   - Look for precision loss in division/multiplication sequences.

## Phase 3: Verification (The "Sui Exploit Engineer" Mindset)
1. **Scenario Identification:**
   - Based on findings, define a concrete attack scenario (e.g., "Attacker steals 1000 SUI by bypassing Capability check").
2. **PoC Implementation:**
   - Create a new Move test file in the `tests/` directory.
   - Use `sui::test_scenario` to simulate transaction sequences and object transfers.
   - Prove the vulnerability by asserting the success of the malicious action.
3. **Report Generation:**
   - Use the standard Code4rena template.
   - Include clear root cause analysis and a link to the reproducible PoC.
