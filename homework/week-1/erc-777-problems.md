# What problems do ERC-777 and ERC-1363 solve?

## Summary of ERC-777

ERC-777 seeks to offer a more automatic way to send and receive ERC-20 tokens. One weakness of ERC-20 is that it requires receivers of tokens to have to monitor for incoming events and then manually respond after receipt.

ERC-777 provides a `send` function that mimics sending with ether, in that it will automatically call callbacks on the receiver.  These callbacks, or hooks, are `tokensReceived` and `tokensToSend`.

This standard specifies how data can be used to give additional information to the receiver.

## Problem with ERC-777

These tokens are subject to reentrancy attack because the receiver of every transaction is given the opportunity to execute commands within the transaction.

The most famous hack was against Uniswap pools that used ERC-777 tokens.  Because the accounting of the token side of the pool was not updated before the transfer call, the attacker could reenter the contract, transfer out all of the ETH, making the token look cheap, then buy up all the token and return the ETH.

> It is not clear to me if this is a problem that Uniswap could have avoided with check-effects or a reentrancy guard?

ERC-777 is also not compatible with ERC-20, as in it doesn't specify that the token must support ERC-20 functions.  After the Uniswap exploit, I think this is the reason there has not been an attempt to re-adopt it in a safe way.

## ERC-1363 responds to ERC-777 short-comings

ERC-1363 aims to provide callback functionality, like ERC-777, but also includes ERC-20 compatibility.  It builds off of `transferAndCall` from ERC-677 (used by Chainlink's LINK token) and adds `transferFromAndCall` and `approveAndCall`.

The `ERC1363Spender` and `ERC1363Receiver` interfaces specify the callback signatures for the respective sender and receiver.

> Are there prominent ERC-1363 tokens?

## Useful Reading

[History of ERC token standards](https://medium.com/immunefi/how-erc-standards-work-part-1-c9795803f459)

I found Dexaran's comments across many forums to be amusing.  He is the developer of the competing [ERC-223](https://github.com/Dexaran/ERC223-token-standard) standard and a harsh advocate against ERC-20s inherent susceptibility in its `transfer` paradigm to accidentally transfer and lose tokens to contracts that don't support ERC-20.  For example, USDT's contract is holding USDT in its own address and has no ability to transfer those back to senders who accidentally sent to the contract itself, instead of the intended destination.

