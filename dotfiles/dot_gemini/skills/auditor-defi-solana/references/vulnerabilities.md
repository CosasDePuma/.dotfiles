# Common Solana & Rust Vulnerabilities

## 1. Missing Account Validation (Critical)
- **Signer Bypass:** Failing to check if an account that should be a signer actually signed the transaction. This allows attackers to perform actions on behalf of other users.
- **Ownership Bypass:** Not checking if an account is owned by the program. This allows attackers to pass in "fake" accounts with malicious data.
- **Account Confusion:** Passing an account of the wrong type (e.g., passing a User Profile account where a Treasury account is expected) if the program doesn't check discriminators.

## 2. PDA Exploits
- **PDA Collision:** Using seeds that are not unique enough, allowing an attacker to derive a PDA that overlaps with another legitimate PDA.
- **Missing Bump Check:** Failing to verify the bump seed, allowing an attacker to provide a different bump that might lead to a different (unintended) PDA.

## 3. Arithmetic & Logic Errors
- **Integer Overflow/Underflow:** Rust wraps in release mode. Forgetting to use `checked_` arithmetic in reward or balance calculations.
- **Precision Loss:** Multiplying before dividing or using incorrect decimal scales when interacting with SPL tokens.
- **Insecure Randomness:** Relying on slot hashes or timestamps for critical logic, which can be manipulated by validators.

## 4. CPI (Cross-Program Invocation) Risks
- **Arbitrary CPI:** Allowing a user to specify the `program_id` for a CPI without validation, leading to calls to malicious programs.
- **Incomplete Account Verification during CPI:** Failing to verify the accounts being passed to a CPI are the correct ones.

## 5. Program State & Initialization
- **Unprotected Initialization:** Failing to check if an account has already been initialized, allowing an attacker to re-initialize it and wipe the state.
- **Anchor Discriminator Issues:** Manual account deserialization that bypasses Anchor's automatic discriminator checks.
