# Common Sui Move Vulnerabilities

## 1. Missing Access Control (Capabilities)
- **Bypassing Capability Pattern:** Forgetting to require a `Capability` object for sensitive administrative actions.
- **Leaked Capabilities:** Storing a capability in a way that is accessible to unauthorized users (e.g., incorrect `store` ability).
- **Public Entry Functions:** Marking functions as `entry public` when they should be `entry fun` (only callable via transactions), or not checking the caller's address/capability inside them.

## 2. Object & Resource Safety
- **Arbitrary Object Ingestion:** Accepting objects without validating their ID or ownership. An attacker could provide a "fake" object that mimics a legitimate one.
- **Incorrect Object Deletion:** Failing to delete or properly manage objects that are no longer needed, potentially leading to state bloat or logic errors.
- **Object Wrapping/Unwrapping Issues:** Incorrectly wrapping an object into another, making it inaccessible or allowing its state to be modified in unintended ways.
- **Frozen Object Modification:** Attempting to modify or incorrectly handle objects that have been frozen (immutable).

## 3. Programmable Transaction Block (PTB) Risks
- **Flash Loan Manipulation:** Vulnerabilities in how PTBs handle flash loans, especially when there's a delay between taking and returning funds.
- **Atomicity Assumptions:** Assuming multiple steps in a PTB are independent when they can be combined by an attacker to manipulate state.
- **Callback Manipulation:** If a function uses a callback or return value in a PTB, an attacker can use it as a "hook" to perform unintended actions before the transaction finishes.

## 4. Coin & Balance Handling
- **Missing Zero Balance Checks:** Allowing operations on empty `Coin` or `Balance` objects that might lead to unexpected logic paths.
- **Incorrect Splitting/Joining:** Bugs in splitting or joining `Coin` objects that could result in rounding errors or lost funds.
- **Insufficient Precision:** Using incorrect decimal scales for different coins (SUI uses 9 decimals).

## 5. Logic & Arithmetic
- **Integer Overflow/Underflow:** Sui Move does not automatically check for arithmetic overflows in all operations; always use `std::u64` or `std::u128` with proper checks.
- **Incorrect ID Comparison:** Using `uid_to_address` instead of `object::id` for comparisons, which can be bypassed.
- **Timestamp Dependency:** Relying on `sui::clock` for critical logic where high precision or validator manipulation could be an issue.
