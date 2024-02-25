// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CappedNFT} from "../../../src/week-2/hw4-ecosystem1/CappedNFT.sol";

contract TestCappedNFT is Test{
    address alice;
    CappedNFT token;

    function setUp() public {
        alice = makeAddr("alice");
        vm.prank(alice);
        token = new CappedNFT();
        token.mint(alice);
    }

    function test_Balance() external{
        assertEq(token.balanceOf(alice), 1);
    }

    function test_Royalty() external {
        // Send purchase price of 1000, contract has 2.5% royalty, so 25 expected.
        (address royaltyReceiver, uint256 royaltyFraction) = token.royaltyInfo(0, 1000);
        assertEq(royaltyReceiver, alice);
        assertEq(royaltyFraction, 25);
    }
}