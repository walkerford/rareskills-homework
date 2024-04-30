# Week 10-11 Security Part 2

## Solidity Riddles -- Forwarder

This comprises two contracts, a wallet and a forwarder. The wallet is seeded
with funds and has a withdraw function that only the forwarder to call. The
forwarder has one function that takes data as bytes, and then uses that data to
call a function on wallet.

To get the funds out, you have to create a contract that calls to the forwarder
contract with the right abi encoded data, which includes the 4-byte hashed
function selector, a receiver's address, and an amount of ether to send from the
wallet.

## Damn Vulnerable Defi -- Truster

Truster is a pool that makes free flash-loans. Upon requesting a flash-loan, the
pool will make an external call on a target of your choice. The pool's balance
must be the same or grater after the flash-loan.

The vulnerability is that the external call is being made with the pool as the
msg.sender, and borrower gets to specify the target and calldata. This allows
the borrower to impersonate the pool. An attacker can request a flash-loan,
specify the token as the target for the external call, and craft the calldata to
call the `approve()` function, which gives approval from the pool for the
attacker to transfer all of the tokens away after the flash-loan completes. In
order to satisfy the after-loan balance requirements, the flash-loan is
requested with the pool as the receiver. Because there is no fee, the flash-loan
will transfer nothing away from the pool, which satisfies the balance
requirement. After the loan the attacker can call `transferFrom()` to claim the
tokens.

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
constructor is 0. The attacker must deploy 5 additional contracts that each mint
and transfer a new NFT from their constructor.

## Democracy

This contract simulates a voting system that is rigged. When the challenger is
nominated, the challenger is given two votes, but the vote count is rigger so
that even when the challenger votes with both votes, the outcome will be a tie
and the incumbent will win.

The vulnerability is that NFT used for voting can be transferred after voting,
giving other accounts the ability to vote. Although this contract prevents
contracts from voting, the voting NFT can still be transferred to another EOA.
In the case of this contract, three votes need to be cast. The challenger
transfers one of his votes to a friend, and then votes for himself. The
challenger then transfers his second vote to the friend. The friend votes twice,
which breaks the tie, allowing the challenger to win and claim the funds.

## Gatekeeper One

This contract provides a set of three modifier which act as gates that one must
pass in order to be made the "entrant".

The first gate requires that the tx.origin be different from the msg.sender.
This is accomplished by calling into a separate contract to make the call to the
gate contract.

The second gate requires a specific amount of gas is provided. I determined the
amount by using a for loop with a try-catch until a successful entry was made.

The third gate requires a key that passes some typecasting checks. It is passed
by creating a key from tx.origin with its bytes 2 and 3 zeroed out.

## Solidity Riddles -- Delete User

This contract uses an array to keep track of ETH deposits. Deposit owners can
also withdraw.

The vulnerability is that the withdraw allows you to specify the index of the
deposit to draw from. After transferring, instead of removing the specified
entry from the array, the last entry is popped off. This allows the user to make
a double deposit, with the second deposit being zero (a dummy entry). Then, when
withdraw is called using the index of the first entry, the contract delivers the
ether for the first entry, and pops the last entry (the dummy entry). This
allows the attack to keep withdrawing, as long as the attacker keeps make
additional dummy deposit entries.

## Viceroy

This contract is a puzzle to release 10 ether. The attacker is minted 1 NFT,
which gives him the opportunity to appoint a viceroy, who creates a proposal and
approves voters to vote on the proposal. When a proposal gets 10 votes, it gets
executed, potentially unlocking the funds. The attacker must complete the
challenge in one transaction.

The contract attempts to ensure only EOAs are registered as viceroys and voters,
which would make it impossible to solve in only one transaction. It uses
`code.data.length` to validate the address is an EOA, but this can be thwarted
by triggering authorization during a new contract's constructor, when it has a
code size of zero, fooling the EOA check.

The contract also limits the viceroy to approving only 5 voters, who can only
vote once each. The proposal needs 10 votes total to pass, so you have to depose
the first viceroy after the first five voters have voted, appoint a new viceroy,
and create 5 more voters to cast the rest of the votes.

The proposal is an abi encoded function selector for the `exec()` function on
the CommunityWallet. Encoding with the right arguments will cause the wallet to
transfer all of its funds to the address you specify.

## Dex2

This contract is a variation on Dex1. It allows two tokens to be swapped. The
pricing function is the ratio of each token held by the dex.

The update is that Dex2 does not validate that the to/from addresses are only
the token addresses supported by the dex. The can be exploited by deploying a
contract that simulates an ERC20 token, but provides a balanceOf 1 for any
address. The attacker makes a swap, specifying the exploit token as the "from"
token. The dex will determine that the dex's balance in the exploit token is 1,
which becomes the denominator of the pricing function, which results in a swap
amount that equals the balance of the "to" token in the swap. The attacker then
gets all of the "to" token.

The swap is performed on both tokens in the dex to drain both.

## Damn Vulnerable Defi -- #2 Native Receiver

Two contracts included here: a flash-loan pool and receiver. Both are dealt
ether to start. The flash loan fee costs 1 ether. To goal is to get the
flash-loan pool to steal the ether from the receiver.

The vulnerability is in the receiver, who fails to validate the msg.sender in
its onFlashLoan() callback. This allows anyone to request a flashLoan and then
use the vulnerable receiver's address as the receiver. The pool will do a
flash-loan and charge the receiver 1 ether. The receiver blindly sends the fee
to the pool every time the callback is called. Call the loan 10 times to deplete
the receivers stock of 10 ether.

## Rareskills Riddles -- Reward Token

This contract allows you to stake an NFT in order to earn rewards. The NFT can
only be staked once and there is a cap on the number of tokens. In order to
solve the puzzle, you must withdraw all of the reward tokens in one transaction.

There are two claim functions, one that withdraws the NFT and one that does not.
The withdraw function makes an external call and fails to update the contract
state before making this call. This allows the attacker, as a part of the
withdrawn process, the opportunity to reenter by calling the other claim
function, which doubles the earnings.

## Rareskills Riddles -- ReadOnly

This contract provides a liquidity pool where ether can be deposited in order to mint shares. The shareholder can later cash in the shares to receive their liquidity plus their share of the fees.

Another defi contract uses the pool as a price oracle. The defi's price can be refreshed by anyone at any time, and this should be ok because the pool's price feed should always be accurate. However, the price feed is not updated before the withdraw callback, and the attacker can trigger a price refresh on the defi contract during this time. The attacker would be able to take advantage of the defi contract afterwards.

`removeLiquidity()` does not burn the tokens (line 72) until after the external call (line 69). There is no way to add reentrancy protection in the defi contract because it is a separate contract from the pool.

# Questions for Review

I am a little uncertain of my solution for Overmint3 and Democracy.

In Overmint3, I used one contract to spin off several contracts, which could
individually mint and transfer a new token. This means the initial contract has
a nonce that is larger than 1. The player still has a nonce of one because he
only initiated one call. The test checks the player nonce only, which makes me
feel like I could have missed another way to do it without the extra contracts.

In Democracy, I didn't have to create any extra contracts. Instead, I created a
2nd EOA wallet to transfer the votes to. Was this legal to do, or did I miss
another solution with a contract?

In Delete User, the instructions note storage pointer. The riddle doesn't seem
to have anything to do with storage pointers though. There is one misleading
line (line 31) that does nothing, and I wonder if that was remnant of of some
other bug that actually tested storage pointers.

## NaiveReceiver

Why doesn't this expectRevert work?

```
    vm.expectRevert();
    receiver.onFlashLoan(address(this), pool.ETH(), 10 ether, 1 ether, "");
```

## RewardToken

I noticed that Foundry does not advance the nonce as expected when making a
method call.
