// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Truster.sol";
import "week10-11-security2/DamnValuableToken.sol";

contract TrusterTest is Test {
    uint256 constant TOKENS_IN_POOL = 1_000_000 ether;

    TrusterLenderPool pool;
    DamnValuableToken token;
    Attacker attacker;

    function setUp() public {
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);
        token.transfer(address(pool), TOKENS_IN_POOL);
        attacker = new Attacker(pool, token);
    }

    function test_setUp() public {
        // Pool should start with 1M tokens
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);

        // Attacker has no balance
        assertEq(token.balanceOf(address(attacker)), 0);
    }

    function test_attack() public {
        attacker.attack();
        _checkSolved();
    }

    function _checkSolved() internal {
        // Pool should have no tokens
        assertEq(token.balanceOf(address(pool)), 0);

        // Attacker should have taken all of the pool's coins
        assertEq(token.balanceOf(address(attacker)), TOKENS_IN_POOL);
    }
}
