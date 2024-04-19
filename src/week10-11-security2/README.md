# Week 10-11 Security Part 2

## Solidity Riddles -- Forwarder

This comprises two contracts, a wallet and a forwarder. The wallet is seeded with funds and has a withdraw function that only the forwarder to call. The forwarder has one function that takes data as bytes, and then uses that data to call a function on wallet.

To get the funds out, you have to create a contract that calls to the forwarder contract with the right abi encoded data, which includes the 4-byte hashed function selector, a receiver's address, and an amount of ether to send from the wallet.

## Damn Vulnerable Defi -- Truster

Truster is a pool that makes free flash-loans. Upon requesting a flash-loan, the pool will make an external call on a target of your choice. The pool's balance must be the same or grater after the flash-loan.

The vulnerability is that the external call is being made with the pool as the msg.sender, and borrower gets to specify the target and calldata. This allows the borrower to impersonate the pool. An attacker can request a flash-loan, specify the token as the target for the external call, and craft the calldata to call the `approve()` function, which gives approval from the pool for the attacker to transfer all of the tokens away after the flash-loan completes. In order to satisfy the after-loan balance requirements, the flash-loan is requested with the pool as the receiver. Because there is no fee, the flash-loan will transfer nothing away from the pool, which satisfies the balance requirement. After the loan the attacker can call `transferFrom()` to claim the tokens.

## Overmint3

This contract allows an address to mint 1 NFT. It does not allow contracts to
mint NFTs. The challenge is to arrive at a balance of 5 NFTs using only one
transaction.

The vulnerability is that NFTs can be transferred, so separate accounts can be
used to mint one NFT each, and then send those to the one player. The way to
generate everything in one transaction is to exploit another vulnerability in
the contract, which is that it checks for code-length in order to reject
contracts, however this can be bypassed by having the attacking contract perform
the functions in its constructor, during which time the code size of the
constructor is 0. The attacker must deploy 5 additional contracts that each
mint and transfer a new NFT from their constructor.

# Democracy

This contract simulates a voting system that is rigged. When the challenger is
nominated, the challenger is given two votes, but the vote count is rigger so
that even when the challenger votes with both votes, the outcome will be a tie
and the incumbent will win.

The vulnerability is that NFT used for voting can be transferred after voting,
giving other accounts the ability to vote. Although this contract prevents
contracts from voting, the voting NFT can still be transferred to another EOA.
In the case of this contract, three votes need to be cast. The challenger
transfers one of his votes to a friend, and then votes for himself. The
challenger then transfers his second vote to the friend. The friend votes
twice, which breaks the tie, allowing the challenger to win and claim the funds.
