// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {SanctionToken, ERC20SanctionedReceiver, ERC20SanctionedSender, ERC20UnauthorizedSanctioner} from "../../src/week1/hw5-SanctionToken.sol";

uint256 constant TOTAL_SUPPLY = 1000e18;

contract SanctionTokenTest is Test {
    SanctionToken token;

    address payable alice;
    address payable bob;

    function setUp() public {
        alice = payable(makeAddr("alice"));
        vm.label(alice, "Alice");

        bob = payable(makeAddr("bob"));
        vm.label(bob, "Bob");

        vm.prank(alice);
        token = new SanctionToken(TOTAL_SUPPLY);

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

    function test_RevertWhen_NonAdminTriesBanning() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20UnauthorizedSanctioner.selector,
                address(this)
            )
        );
        token.ban(bob);
    }

    function test_RevertWhen_SendingToSanctioned() public {
        // Admin bans bob
        vm.prank(alice);
        token.ban(bob);

        // Attempt to send to bob fails
        vm.expectRevert(
            abi.encodeWithSelector(ERC20SanctionedReceiver.selector, bob)
        );
        vm.prank(alice);
        token.transfer(bob, 10e18);
    }

    function test_RevertWhen_SendingFromSanctioned() public {
        // Admin bans bob
        vm.prank(alice);
        token.ban(bob);

        // Attempt to send from bob fails
        vm.expectRevert(
            abi.encodeWithSelector(ERC20SanctionedSender.selector, bob)
        );
        vm.prank(bob);
        token.transfer(alice, 5e18);
    }
}
