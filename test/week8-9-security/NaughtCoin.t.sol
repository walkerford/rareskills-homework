// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week8-9-security/NaughtCoin.sol";
import "week8-9-security/NaughtCoinAttacker.sol";

contract NaughtCoinTest is Test {
    NaughtCoin token;
    NaughtCoinAttacker attacker;

    function setUp() external {
        token = new NaughtCoin(address(this));
        attacker = new NaughtCoinAttacker(token);
    }

    function test_setUp() external {
        assertEq(token.balanceOf(address(this)), 1_000_000e18);
    }

    function test_attack() external {
        uint256 balance = token.balanceOf(address(this));
        token.approve(address(attacker), balance);
        attacker.attack();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(token.balanceOf(address(this)), 0);
    }
}
