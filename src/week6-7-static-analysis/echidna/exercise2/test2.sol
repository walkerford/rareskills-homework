// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./token2.sol";
import "./token2-fixed.sol" as tf;

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise2/template.sol
///      ```
contract TestToken is Token {
    constructor() {
        pause(); // pause the contract
        owner = address(0); // lose ownership
    }

    function echidna_cannot_be_unpause() public view returns (bool) {
        // TODO: add the property
        return (paused() == true);
    }
}

contract TestTokenFixed is tf.Token {
    constructor() {
        pause(); // pause the contract
        owner = address(0); // lose ownership
    }

    function echidna_cannot_be_unpause() public view returns (bool) {
        // TODO: add the property
        return (paused() == true);
    }
}
