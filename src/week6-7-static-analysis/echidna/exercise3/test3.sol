// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./mintable.sol";
import "./mintable-fixed.sol" as mf;

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise3/template.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;
    int256 constant MAX_MINTABLE = 10_000;

    // TODO: update the constructor
    constructor() MintableToken(MAX_MINTABLE) {}

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        // return balances[msg.sender] <= MAX_MINTABLE;
        return totalMinted <= MAX_MINTABLE && totalMinted >= 0;
    }
}

contract TestTokenFixed is mf.MintableToken {
    address echidna = msg.sender;
    uint256 constant MAX_MINTABLE = 10_000;

    // TODO: update the constructor
    constructor() mf.MintableToken(MAX_MINTABLE) {}

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        // return balances[msg.sender] <= MAX_MINTABLE;
        return totalMinted <= MAX_MINTABLE && totalMinted >= 0;
    }
}
