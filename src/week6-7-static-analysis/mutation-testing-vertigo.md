## Mutation testing with vertigo-rs

### Installation notes

The initial install of vertigo failed because it was trying to install itself in a folder it didn't have permission (/Library/...).  In my attempt to get it to install, the python pip cache got corrupted and the package `jsonpath-rw` failed to install properly.  I finally figured out how to clear the python cache and installed that package manually.

### Usage notes

Can't re-run a sample set of mutations

How do you rerun a sub-set of mutations?  The `--sample-ratio` flag is useful to reduce the amount of time it take the mutation test to run, but it is a problem to know whether changes to the testing code have addressed the problem, because you can't rerun the exact subset of mutations a second time.

Should you unit test all constants?

How do you deal with mutation testing on comments?


### Mutation examples

Erasing lines:

```
Mutation:
    File: /Users/walkerford/git/solidity/rareskills/src/week2/hw4-ecosystem1/Staking.sol
    Line nr: 89
    Result: Lived
    Original line:
                 _updateCredits(tokenId);

    Mutated line:
                 
```

Changing math operation:

```
Mutation:
    File: /Users/walkerford/git/solidity/rareskills/src/week2/hw4-ecosystem1/Staking.sol
    Line nr: 10
    Result: Lived
    Original line:
         uint256 constant BLOCKS_PER_PERIOD = SECONDS_PER_PERIOD / SECONDS_PER_BLOCK; // 60*60*24/12=7200

    Mutated line:
         uint256 constant BLOCKS_PER_PERIOD = SECONDS_PER_PERIOD * SECONDS_PER_BLOCK; // 60*60*24/12=7200
```

Removing custom modifiers:

```
Mutation:
    File: /Users/walkerford/git/solidity/rareskills/src/week2/hw4-ecosystem1/LimitedNFT.sol
    Line nr: 28
    Result: Error
    Original line:
             constructor(bytes32 merkleRoot_) ERC721("Limited NFT", "LT") Ownable(msg.sender) { 

    Mutated line:
             constructor(bytes32 merkleRoot_) ERC721("Limited NFT", "LT")  { 
```

Changing equals sign:

```
Mutation:
    File: /Users/walkerford/git/solidity/rareskills/src/week2/hw4-ecosystem1/RewardToken.sol
    Line nr: 10
    Result: Killed
    Original line:
                 if (to == address(0)) revert ERC20InvalidReceiver(to);

    Mutated line:
                 if (to != address(0)) revert ERC20InvalidReceiver(to);
```

