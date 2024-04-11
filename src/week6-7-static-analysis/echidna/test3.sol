// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./mintable.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise3/template.sol --contract TestToken
///      ```
contract TestToken3 is MintableToken {
    address echidna = msg.sender;

    uint256 constant MAX_MINTABLE = 10_000;

    // TODO: update the constructor
    constructor() MintableToken(MAX_MINTABLE) {
        owner = tx.origin;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        // return totalMinted <= MAX_MINTABLE && totalMinted >= 0;
        return balances[msg.sender] <= MAX_MINTABLE;
    }
}
