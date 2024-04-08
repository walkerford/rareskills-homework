// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week6-7-static-analysis/echidna1/token.sol";

contract Echidna1Test is Test {
    TestToken token;
    address echidna;

    function setUp() external {
        token = new TestToken();
        echidna = tx.origin;
    }

    function test() external {
        console.log("tx.origin", tx.origin);
        console.log("msg.sender", msg.sender);
        console.log("address(echidna)", address(echidna));
        console.log("address(this)", address(this));
        token.transfer(echidna, 1);
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