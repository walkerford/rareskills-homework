# Week 6-7 Static Analysis and Fuzz Testings

In this week we go over the static analysis tool `slither`, the mutation testing
tool `vertigo-rs` and the fuzz testing tool `echidna`.

I installed a VSCode extension called "Coverage Gutters", which allows me to see
which lines are missing testing coverage in a source file.

## Static Analysis and Mutation Testing

[x] Run slither on the uniswap codebase

[x] Document the types of true and false positives that result
[static-analysis-slither.md](./static-analysis-slither.md)

[x] Ensure ERC721 / ERC20 / Staking application has 100% code coverage

[x] Run `vertigo-rs` and document the mutations that are discovered.
[mutation-testing-vertigo.md](./mutation-testing-vertigo.md)

```
$ forge coverage

| src/week2/hw4-ecosystem1/LimitedNFT.sol                                        | 100.00% (17/17)  | 100.00% (28/28)   | 100.00% (12/12)  | 100.00% (5/5)    |
| src/week2/hw4-ecosystem1/RewardToken.sol                                       | 100.00% (2/2)    | 100.00% (4/4)     | 100.00% (2/2)    | 100.00% (1/1)    |
| src/week2/hw4-ecosystem1/Staking.sol                                           | 100.00% (31/31)  | 100.00% (39/39)   | 100.00% (10/10)  | 100.00% (8/8)    |

```

## Fuzz testing

Each echidna exercise has its own folder with config and a Makefile to run the
command. Change into the directory for each exercise before running one of the
following commands:

`make echidna-fail` tests the contract and shows a failing test. `make
echidna-pass` tests the fixed contract and shows passing tests.

Check each Makefile for other variants.

[x] Echidna exercise 1

[x] Echidna exercise 2

[x] Echidna exercise 3

[x] Echidna exercise 4

[x] Capture the Ether -- Token Whale

[x] Capture the Ether -- Dex1

[x] BondCurveToken.sol

Created a wrapper, since the BondCurveToken constructor requires an argument.

First, I ran the overflow fuzz test. It produced several errors, but these were
all over/under-flows that were properly being handled in the code. Instead, what
this was telling me was that I needed to validate echidna inputs better -- make
echidna not send obviously invalid inputs. I added input validation and
eventually the overflow fuzz test passed. This gives me some confidence that my
wrapper is better set up for valid inputs for testing.

When echidna throws an error, I use foundry to help me better understand what is
going on. Echidna doesn't give very good stack traces, and no console.log(), so
debugging is difficult.

Echidna showed me that buying 1 token costs zero, which breaks the invariant
that I had. This happens because the price of 1 is 0.5, which rounds down to
integer 0. I just updated the invariant to include the free token.

Echidna showed me I was handling the units incorrectly. I was dividing by 1e18
incorrectly. I was confused originally whether I wanted one token to cost 1
ether or 1 wei. I'm sticking with 1 wei for simplicity.

The only property that I implemented was to make sure the contract balance never
went to zero while there were still tokens in supply.

## Questions

What are some other property recommendations for the BondCurveToken?

Are there other helpful tips for debugging echidna? Like, how do you view what
tests were run with echidna? Can you view console.log outputs somehow?
