# Week 10-11 Security Part 2

## Solidity Riddles -- Forwarder

This comprises two contracts, a wallet and a forwarder. The wallet is seeded with funds and has a withdraw function that only the forwarder to call. The forwarder has one function that takes data as bytes, and then uses that data to call a function on wallet.

To get the funds out, you have to create a contract that calls to the forwarder contract with the right abi encoded data, which includes the 4-byte hashed function selector, a receiver's address, and an amount of ether to send from the wallet.
