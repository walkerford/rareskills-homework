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

    function test_attack() external {}

    function _checkSovled() internal {
        // Token price should be zero
        assertEq(vulnerable.lpTokenPrice(), 0);

        // Should solve in one transaction
    }
}
