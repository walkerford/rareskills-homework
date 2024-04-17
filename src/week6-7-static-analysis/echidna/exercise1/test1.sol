// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./token1.sol";
import "./token1-fixed.sol" as tf;

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise1/template.sol
///      ```
contract TestToken is Token {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        return balances[echidna] <= 10_000;
    }
}

contract TestTokenFixed is tf.Token {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        return balances[echidna] <= 10_000;
    }
}
