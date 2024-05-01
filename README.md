## Rareskills-homework

This is my work for the [Rareskills](https://www.rareskills.io/) [Advanced
Solidity program](https://www.rareskills.io/solidity-bootcamp).

I am using [Foundry](https://github.com/foundry-rs/foundry) as the execution and
unit-testing framework for my solidity contracts.

Summaries of each week's assignments and source code are located in the `src/`
folder within their respective assigned week sub-folder.

Test contracts are found in the `test/` folder. In many cases, solutions to the
puzzles include steps within the test files in addition to the contract code in
the src folder.

Run the whole test suite with:

```
forge test
```

Or individual tests with:

```
forge test --match-contract [test contract name]
```

Initial build throws some warnings from openzeppelin-v4, for some reason, but
otherwise everything builds cleanly and all tests should pass.

Some puzzles were ported from earlier versions of solidity to ^0.8.0, and from
openzeppelin-v3 to openzeppelin-v4 or -v5.

### Hardhat

There is one hardhat projects that I never ported to Forge: Overmint1. Run the
Overmint1 test like so:

```
npx hardhat test test/week8-9-security/Overmint1-ERC1155.js
```

I also wrote a hardhat project called NonceTest. I wrote this to try to figure
out a Foundry equivalent to Hardhat's `getTransactionCount()`, but I have not
yet solve it.

Run that test like so:

```
npx hardhat test test/week10-11-security2/Nonce.js
forge test --match-contract NonceTest
```

### Echidna

All echidna test are self-contained in individual folders and have an associated
Makefile. Check the Makefile for the recipes.
