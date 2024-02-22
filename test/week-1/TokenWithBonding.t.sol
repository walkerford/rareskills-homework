// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {TokenWithBonding} from "../../src/week-1/TokenWithBonding.sol";

contract TokenWithBondingTest is Test {
    TokenWithBonding token;

    address payable alice;
    address payable bob;

    function setUp() public {
        alice = payable(makeAddr("alice"));
        vm.label(alice, "Alice");
        vm.deal(alice, 10 ether);

        bob = payable(makeAddr("bob"));
        vm.label(bob, "Bob");

        vm.prank(alice);
        token = new TokenWithBonding(0);
    }

    function test_LinearPurchase() public {
        vm.prank(alice);
        token.purchase{value: 1 ether / 2}(1e18);
        assertEq(token.balanceOf(alice), 1e18);

        assertEq(token.totalSupply(), 1e18);
    }
}
