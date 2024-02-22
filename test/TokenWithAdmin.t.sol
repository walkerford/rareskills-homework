// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {TokenWithAdmin} from "../src/TokenWithAdmin.sol";

uint256 constant TOTAL_SUPPLY = 1000e18;

contract TokenWithAdminTest is Test {
    TokenWithAdmin token;

    address payable alice;
    address payable bob;

    function setUp() public {
        alice = payable(makeAddr("alice"));
        vm.label(alice, "Alice");

        bob = payable(makeAddr("bob"));
        vm.label(bob, "Bob");

        vm.prank(alice);
        token = new TokenWithAdmin(TOTAL_SUPPLY);

        vm.prank(alice);
        token.transfer(bob, 10e18);
    }

    function test_ValidateTotalSupply() public {
        uint256 totalSupply = token.totalSupply();
        assertEq(totalSupply, TOTAL_SUPPLY);
    }

    function test_UserHasBalance() public {
        assertEq(token.balanceOf(bob), 10e18);
    }

    function test_AdminCanTransferForAnother() public {
        vm.prank(alice);
        token.transferFrom(bob, alice, 6e18);
        assertEq(token.balanceOf(bob), 4e18);
    }
}
