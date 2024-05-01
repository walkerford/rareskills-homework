// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/DamnValuableTokenSnapshot.sol";
import "week10-11-security2/selfie/SimpleGovernance.sol";
import "week10-11-security2/selfie/SelfiePool.sol";
import "week10-11-security2/selfie/SelfiePoolAttacker.sol";

contract SelfieTest is Test {
    uint256 constant TOKEN_INITIAL_SUPPLY = 2_000_000 ether;
    uint256 constant TOKENS_IN_POOL = 1_500_000 ether;

    address attackerWallet;
    DamnValuableTokenSnapshot dvt;
    SimpleGovernance gov;
    SelfiePool pool;

    function setUp() external {
        attackerWallet = makeAddr("attackerWallet");
        dvt = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);
        gov = new SimpleGovernance(address(dvt));
        pool = new SelfiePool(address(dvt), address(gov));

        dvt.transfer(address(pool), TOKENS_IN_POOL);
    }

    function test_setUp() external {
        // Selfie pool should have 1.5M tokens
        assertEq(dvt.balanceOf(address(pool)), 1_500_000 ether);

        // Attacker should have 0 tokens
        assertEq(dvt.balanceOf(attackerWallet), 0);
    }

    function test_attack() external {
        vm.prank(attackerWallet);
        SelfieAttacker attacker = new SelfieAttacker(pool);

        // Attack
        attacker.attack();

        // Wait 2 days
        skip(2 days);

        // Drain funds
        attacker.finish();

        _checkSolved();
    }

    function _checkSolved() internal {
        // Attacker should have all the tokens
        assertEq(dvt.balanceOf(attackerWallet), TOKENS_IN_POOL);

        // Pool should have nothing
        assertEq(dvt.balanceOf(address(pool)), 0);
    }
}
