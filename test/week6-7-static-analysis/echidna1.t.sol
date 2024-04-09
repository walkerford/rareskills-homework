// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week6-7-static-analysis/echidna/token.sol";

contract EchidnaTest is Test {
    TestToken token;
    address echidna;

    function setUp() external {
        token = new TestToken();
        echidna = tx.origin;
    }

    // function test_RevertsWhen() external {
    function test_RevertsWhen() external view {
        console.log("tx.origin", tx.origin);
        console.log("msg.sender", msg.sender);
        console.log("address(echidna)", address(echidna));
        console.log("address(this)", address(this));
        // token.transfer(echidna, 1);
        console.log("balances[echidna]", token.balances(echidna));
        console.log("balances[this]", token.balances(address(this)));
    }
}

contract TestToken is Token {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }
}
