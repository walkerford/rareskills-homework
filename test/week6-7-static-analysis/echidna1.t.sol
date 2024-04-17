// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
// import "week6-7-static-analysis/echidna/exercise3/token3.sol" as token3;
import "week6-7-static-analysis/echidna/exercise3/mintable.sol";
import "week6-7-static-analysis/echidna/exercise3/test3.sol" as test3;

contract EchidnaExperiments is Test {
    address echidna;
    TestToken0 token;
    test3.TestToken testToken3;
    MintableToken mintable;

    function setUp() external {
        echidna = tx.origin;
        token = new TestToken0();
        testToken3 = new test3.TestToken();
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

        console.log("totalMintable", uint256(testToken3.totalMintable()));
    }

    function test_mint() external {
        vm.startPrank(address(this));
        testToken3.mint(1_000);
        assert(testToken3.balances(address(this)) == 1_000);
        vm.stopPrank();
    }
}

contract TestToken0 is Token {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }
}
