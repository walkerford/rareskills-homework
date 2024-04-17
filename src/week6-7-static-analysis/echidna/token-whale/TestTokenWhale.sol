// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./TokenWhale.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise3/template.sol --contract TestToken
///      ```
contract TestTokenWhale is TokenWhale {
    constructor() TokenWhale(msg.sender) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }
}
