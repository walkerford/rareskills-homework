// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/ReadOnly.sol";

contract ReadOnlyTest is Test {
    ReadOnlyPool pool;
    VulnerableDeFiContract vulnerable;
    address alice;

    function setUp() external {
        pool = new ReadOnlyPool();
        vulnerable = new VulnerableDeFiContract(pool);

        pool.addLiquidity{value: 100 ether}();

        pool.earnProfit{value: 1 ether}();

        vulnerable.snapshotPrice();

        alice = makeAddr("alice");
        vm.deal(alice, 2 ether);
    }

    function test_setUp() external {
        assertEq(address(pool).balance, 101 ether);
        assertEq(alice.balance, 2 ether);
        assertEq(vulnerable.lpTokenPrice(), 1);
    }

    function test_attack() external {
        // Deploy attacking contract
        vm.prank(alice);
        ReadOnlyAttacker attacker = new ReadOnlyAttacker{value: alice.balance}(
            pool,
            vulnerable
        );

        // Start attack The attack will add liquidity, then remove it, which
        // triggers a callback.  In the callback, before all of the state has
        // been updated, the attacker can call `snapshotPricee()` which will
        // generate a 0 price.
        vm.prank(alice);
        attacker.attack();

        _checkSolved();
    }

    function _checkSolved() internal {
        // Token price should be zero
        assertEq(vulnerable.lpTokenPrice(), 0);

        // Should solve in one transaction
    }
}
