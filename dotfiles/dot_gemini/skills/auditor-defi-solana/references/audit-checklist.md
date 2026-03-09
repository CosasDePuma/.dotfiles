# Expert Solana & Rust Audit Methodology

Use this reference to ensure account safety, instruction integrity, and secure fund management in Solana programs.

## 1. Account Validation & Ownership
- **Signer Check:** Ensure critical instructions verify that necessary accounts are signers (e.g., `account.is_signer`). In Anchor, use `#[account(signer)]`.
- **Ownership Check:** Verify that account ownership belongs to the expected program (e.g., the current program or the Token Program). In Anchor, use `#[account(owner = ...)]`.
- **Account Data Matching:** Check that the account provided is actually the one expected (e.g., checking an ID or a discriminator). Avoid "Account Confusions".

## 2. PDA (Program Derived Addresses) Safety
- **Derivation Validation:** Verify that PDAs are derived using the correct seeds and the expected program ID.
- **PDA Collisions:** Check if multiple sets of seeds can derive the same PDA, potentially leading to state overwrites.
- **Bump Seed Validation:** Ensure that the bump seed is verified during `find_program_address` or passed correctly to `create_program_address`.

## 3. Instruction Logic & Math
- **Checked Arithmetic:** Rust's default behavior in release mode is to wrap on overflow. Always use `checked_add`, `checked_sub`, etc., or the `SafeMath` patterns.
- **Decimal Precision:** Solana's `Token Program` uses various decimals. Ensure all calculations account for decimal differences between tokens.
- **Rounding Direction:** Round in favor of the protocol (e.g., round down for user rewards, round up for user debts).

## 4. Cross-Program Invocations (CPI)
- **Target Program Validation:** When performing a CPI, verify that the `program_id` of the target account is the one expected (e.g., verifying it's the real Token Program).
- **Return Value Check:** Some older programs or custom CPIs might return values that need checking. Ensure CPIs succeeded as expected.
- **Reentrancy via CPI:** While Solana doesn't have EVM-style reentrancy, a malicious program called via CPI can call back into the original program if it doesn't handle state updates atomically.

## 5. Account Bloat & Rent
- **Account Size:** Verify that accounts are allocated with enough space for future upgrades but not so much that rent becomes prohibitive.
- **Rent Exemption:** Ensure all new accounts are funded with enough SOL to be rent-exempt.
