# Week 8-9 -- Security Puzzles

We were assigned 13 puzzles to solve over two weeks. Here are some notes on the
vulnerabilities that were discovered in each.

## Capture the Ether -- Guess the Secret Number

This contract pays a reward to the first person who can guess the secret number
that it is compiled with.

Because the bytecode is published onto the blockchain, anyone who is able to
interpret the bytecode can determine the secret number. In our case, we had the
source code and could take the secret number directly from it.

Secret information should not be encoded directly into the contract.

## Capture the Ether -- Guess the New Number

This contract pays a reward to the first person to guess its random number. It
derives the random number using a hash of the block number of the previous
block.

This number can be easily guessed because the secret number algorithm is
viewable by everyone and everyone has access to all of the information required
to calculate the number.

Using information from a previous block for a random number is usually a bad
idea, since the information is available to everyone.

## Capture the Ether -- Predict the Future

This contract pays a reward to someone who can predict the secret number that
will be generated in the future, using the hash of a future block.

The number generating algorithm is published within the contract, so it can be
replayed on data until a result matches the guess. The attacker can submit an
arbitrary guess, then wait until a block produces a result that matches his
guess, and finally submit a settle transaction in the following block to settle
the contract.

Again, because any block data that is committed to the chain can be viewed by
everyone, relying on this data alone to generate a random number is subject to
exploitation. Although a future block is used from the perspective of the
original guess, from the perspective of the settlement the critical block is in
its past and visible to the exploiter.

## Rareskills Riddle -- ERC1155 (Overmint)

This contract limits minting of an NFT to 3 units per address. The challenge is
to mint 5 NFTs.

The vulnerability is that the limit is imposed by checking the player's current
balance. During the mint transaction, the player can transfer newly minted NFTs
to another address and thereby continue to mint beyond the limit.

## Capture the Ether -- Token Bank

The contract is a vault for an ERC-223 token. The ERC-223 aims to act like
native ether in that it specifies a fallback function that gets called whenever
the token is transferred.

The vault implementation is subject to a reentrancy attack because it modifies
its state after the external calls are made. The attacker can deploy a contract
with a fallback function that performs the attack. Prior to deploying, the
attacker must transfer his token balance to the attacking contract.

## Capture the Ether -- Predict the Block Hash

The contract will pay a reward if you can guess the hash of a future block.

The vulnerability is that the solidity hash function used by the contract
returns 0 when the block is greater than 256 blocks away. The attacker simply
guesses zero and then waits until 256 blocks pass to claim his reward.

## Capture the Ether -- Token Whale

This contract is ERC-like and allocates an initial supply of tokens.

The vulnerability is that it's internal transfer() function assumes the
msg.sender is the token owner. This is not the case for transferFrom() calls.
The unchecked internal accounting under-flows when transferring from an account
with zero tokens, on behalf of an account that has tokens. The attacking
contract then receives type(uint256).max amount of tokens.

## Capture the Ether -- Token Sale

This contract offers tokens for sale at a fixed price.

The vulnerability is that the cost function in buy() uses unchecked math and can
overflow if the number of tokens requested is very large. This results in a very
small price for a large number of tokens. After completing such a buy, the
attacker can then sell some of his pile of tokens in order to drain the
preexisting ether from the contract.

## Capture the Ether -- Retirement Fund

The contract custodies an amount of funds for a user. The funds can be withdrawn
after a later date for free. If the funds are withdrawn early, a beneficiary
receives a portion of the funds.

The vulnerability is that this contract uses a combination of unchecked math and
address(this).balance, which can be exploited to produce an underflow. The
contract assumes that its balance never changes, however an attacker can send
ether to the contract through the selfdestruct of another contract, to increase
its balance. This will result in a math underflow in the collectPenalty()
function, which makes it think an early withdrawal occurred and that it should
drain the remaining ether to the beneficiary.

## Damn Vulnerable Defi -- Side Entrance

This contract takes in deposits and offers free flash loans of ether to users.

The vulnerability is that the flash loan uses address(this).balance to validate
that the funds have been returned. An attacker can take a flash-loan and then
deposit those funds into his account with the contract, making it seem like the
contract has received its collateral back. The attacker, who now has a positive
balance with the contract, can withdraw all of the ether.

## Damn Vulnerable Defi -- Unstoppable

The contract is an ERC4626 token vault. Users can deposit into the vault and
receive shares in return. Flash-loans from the deposited funds are made
available for a fee when above a certain amount or after a certain time. The
contract has an invariant that shares exist 1-to-1 with the underlying asset.

The vulnerability is that the share quantity calculation is dependent upon the
balance in the contract. During a large enough flash loan (the amount is half or
more of the total supply), an attacker can deposit 1 asset and receive 2 shares
instead of 1. The fact that 2 shares were minted and only 1 asset deposited will
break the invariant and cause the contract to stop making loans.

## Ethernaut -- #20 Denial

This contract holds funds and allows a withdrawal to be split between two
people, one of which pays the gas for the transaction.

The vulnerability is in the form of a denial of service. The contract that
initiates the withdrawal gets called with the entire amount of gas for the
transaction. It can then exhaust the gas and cause the transaction to halt,
preventing either parties from withdrawing.

## Ethernaut -- #15 Naught Coin

This contract is an ERC20 with a custom transfer function that puts limits on
withdrawal.

The vulnerability is that the transfer limits are not applied to transferFrom(),
so an attacker can take his tokens by using a contract to transfer them on his
behalf.
