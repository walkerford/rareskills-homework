// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week6-7-static-analysis/echidna/token.sol";
import "week6-7-static-analysis/echidna/mintable.sol";
import "week6-7-static-analysis/echidna/test3.sol";

contract EchidnaExperiments is Test {
    TestToken token;
    address echidna;
    TestToken3 testToken3;
    MintableToken mintable;

    function setUp() external {
        token = new TestToken();
        echidna = tx.origin;
        testToken3 = new TestToken3();
        mintable = new MintableToken(10_000);
    }

    // Ignoring for now
    function _test0() external {
        console.log("tx.origin", tx.origin);
        console.log("msg.sender", msg.sender);
        console.log("address(echidna)", address(echidna));
        console.log("address(this)", address(this));
        token.transfer(echidna, 1);
        console.log("balances[echidna]", token.balances(echidna));
        console.log("balances[this]", token.balances(address(this)));
    }

    function test1() external view {
        // I want to confirm various addresses
        console.log("Confirming some addresses:");

        // Why do TestToken3 and Mintable have different msg.sender?

        // TestToken3's owner is explicitely set to the tx.origin, where in
        // Mintable its owner is derived from the msg.sender, which is this
        // contract, which is a different address from msg.sender.

        console.log("TestToken3 tx.origin", tx.origin);
        // TestToken3 tx.origin 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

        console.log("TestToken3 msg.sender", msg.sender);
        // TestToken3 msg.sender 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

        console.log("TestToken3 owner()", testToken3.owner());
        // TestToken3 owner() 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

        console.log("Mintable owner()", mintable.owner());
        // Mintable owner() 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496

        console.log("address(this)", address(this));
        // address(this) 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496

        console.log();
    }

    function test_mint() external {
        vm.prank(tx.origin);
        testToken3.mint(1_000);
        assert(testToken3.balances(tx.origin) == 1_000);
    }
}

contract TestToken is Token {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }
}
