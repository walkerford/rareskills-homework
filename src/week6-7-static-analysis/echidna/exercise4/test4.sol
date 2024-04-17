// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./token4.sol";
import "./token4-fixed.sol" as tf;

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise4/template.sol --contract TestToken --test-mode assertion
///      ```
///      or by providing a config
///      ```
///      echidna program-analysis/echidna/exercises/exercise4/template.sol --contract TestToken --config program-analysis/echidna/exercises/exercise4/config.yaml
///      ```
contract TestToken is Token {
    function transfer(address to, uint256 value) public override {
        // TODO: include `assert(condition)` statements that
        // detect a breaking invariant on a transfer.
        // Hint: you may use the following to wrap the original function.
        uint256 fromBalanceBefore = balances[msg.sender];
        uint256 toBalanceBefore = balances[to];
        super.transfer(to, value);
        uint256 fromBalanceAfter = balances[msg.sender];
        uint256 toBalanceAfter = balances[to];
        assert(fromBalanceAfter <= fromBalanceBefore);
        assert(toBalanceAfter >= toBalanceBefore);
    }
}

contract TestTokenFixed is tf.Token {
    function transfer(address to, uint256 value) public override {
        // TODO: include `assert(condition)` statements that
        // detect a breaking invariant on a transfer.
        // Hint: you may use the following to wrap the original function.
        uint256 fromBalanceBefore = balances[msg.sender];
        uint256 toBalanceBefore = balances[to];
        super.transfer(to, value);
        uint256 fromBalanceAfter = balances[msg.sender];
        uint256 toBalanceAfter = balances[to];
        assert(fromBalanceAfter <= fromBalanceBefore);
        assert(toBalanceAfter >= toBalanceBefore);
    }
}
