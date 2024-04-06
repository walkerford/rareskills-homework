# Slither notes

- Missing check on return value
- Unnecessary "this" before some calls
- solc version too high
-

week-2

- [#weak-PRNG] (false) Weak PRNG in block.timestamp. This isn't being used as a PRNG.
- [#unchecked-transfer] (true, fixed) Ignored return value of transfer().
- [#dangerous-strict-equalities] (false) Code checks for zeros on purpose.
- [#reentrancy-vulnerabilities-1] (true, addressed) Points out that Pair.swap() and Pair.burn() have reentrancy potential, the functions called and the state variables affected. The reentrancy guard protects against these.
- [#uninitialized-local-variables] (false) Not really an issue, since zero is ok.
- [#missing-zero-address-validation] (true) Was missing zero checks on token addresses.
- [#reentrancy-vulnerabilities-2] (true, addressed) Similar to -1 above.
- [#block-timestamp] (false) Checking for zero just to save on unnecessary math.
- [#boolean-equality] (maybe, fixed) I don't think it was really a problem, but I could change the code to make slither happy.
- [#incorrect-versions-of-solidity] (maybe) Using solidity version that is too new.
- [#low-level-calls] (false) Low-level call is expected.
- [#conformance-to-solidity-naming-conventions] (true, fixed)
- [#variable-names-too-similar] (maybe) In production, I'd probably fix this.
- [#dead-code] (false) Not sure why it thinks code in UQ112x112.sol is dead.

## Questions

How to make slither aware of reentrancy guard?

Why does slither complain about local variables that haven't been initialized, when you are ok with them being zero?

Can you add lines in the code that make slither ignore a line?

What is the right solidity version to use to make slither happy? Is there a way to bypass this check, or update the value that is accepted? In my case, using the recommended slither version broke the version requirement on a dependency.
