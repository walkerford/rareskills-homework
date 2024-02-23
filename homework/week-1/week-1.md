# Homework

1. Create a markdown file about what problems ERC777 and ERC1363 solves. Why was ERC1363 introduced, and what issues are there with ERC777?

[x] erc-777-problems.md

2. Why does the SafeERC20 program exist and when should it be used?

[x] safe-erc20-purpose.md

> What are some examples of non-standard ERC-20 tokens whose transfer functions don't return properly?

3. Token with god mode. A special address is able to transfer tokens between addresses at will.

[x] AdminToken.sol

4. Token sale and buyback with bonding curve. The more tokens a user buys, the more expensive the token becomes. To keep things simple, use a linear bonding curve. 

[x] BondCurveToken.sol

[] Consider the case someone might sandwich attack a bonding curve. What can you do about it?

> One mitigation is to apply a freeze-out period where a buyer cannot sell for some period of time, like not within the same block or longer.
> Adding a separate curve for selling might help dissuade quick sells, but I need to think about that some more.

5. Untrusted escrow. Create a contract where a buyer can put an arbitrary ERC20 token into a contract and a seller can withdraw it 3 days later. Based on your readings above, what issues do you need to defend against? Create the safest version of this that you can while guarding against issues that you cannot control. Does your contract handle fee-on transfer tokens or non-standard ERC20 tokens.

[] EscrowToken.sol

> What is the seller selling: ETH, another token or does this contract provide the token?

> The seller needs to be able to configure the terms of the sale, like the sale price and escrow token type.  The seller's asset and the buyers payment will only be released when the conditions are met.

> Basic flow:
> Seller configures deal
> Buyer submits payment
> Escrow performs appropriate `allowances` on both tokens
> Seller and buyer can both withdraw

> Need to guard against reentrancy with check-effects and possibly also a reentrancy guard.
> Accounting needs to be handled carefully, measure the balance before and after a transfer, so that fees can be accounted for.
> Need to give the buyer a way to retrieve their collateral in the case that the seller does not claim it.
