# Homework

1. Create a markdown file about what problems ERC777 and ERC1363 solves. Why was ERC1363 introduced, and what issues are there with ERC777?

[x] erc-777-problems.md

2. Why does the SafeERC20 program exist and when should it be used?

[x] safe-erc20-purpose.md

3. Token with god mode. A special address is able to transfer tokens between addresses at will.

[x] AdminToken.sol

4. Token sale and buyback with bonding curve. The more tokens a user buys, the more expensive the token becomes. To keep things simple, use a linear bonding curve. 

[x] BondCurveToken.sol
[] Consider the case someone might sandwich attack a bonding curve. What can you do about it?

5.  ERC20 token into a contract and a seller can withdraw it 3 days later. Based on your readings above, what issues do you need to defend against? Create the safest version of this that you can while guarding against issues that you cannot control. Does your contract handle fee-on transfer tokens or non-standard ERC20 tokens.

[] EscrowToken.sol