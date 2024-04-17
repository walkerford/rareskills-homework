# Week 10-11 Security Part 2

## Solidity Riddles -- Forwarder

This comprises two contracts, a wallet and a forwarder. The wallet is seeded with funds and has a withdraw function that only the forwarder to call. The forwarder has one function that takes data as bytes, and then uses that data to call a function on wallet.

To get the funds out, you have to create a contract that calls to the forwarder contract with the right abi encoded data, which includes the 4-byte hashed function selector, a receiver's address, and an amount of ether to send from the wallet.

## Damn Vulnerable Defi -- Truster

Truster is a pool that makes free flash-loans. Upon requesting a flash-loan, the pool will make an external call on a target of your choice. The pool's balance must be the same or grater after the flash-loan.

The vulnerability is that the external call is being made with the pool as the msg.sender, and borrower gets to specify the target and calldata. This allows the borrower to impersonate the pool. An attacker can request a flash-loan, specify the token as the target for the external call, and craft the calldata to call the `approve()` function, which gives approval from the pool for the attacker to transfer all of the tokens away after the flash-loan completes. In order to satisfy the after-loan balance requirements, the flash-loan is requested with the pool as the receiver. Because there is no fee, the flash-loan will transfer nothing away from the pool, which satisfies the balance requirement. After the loan the attacker can call `transferFrom()` to claim the tokens.
