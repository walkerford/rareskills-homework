// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../../../src/week2/hw5-ecosystem2/EnumerableNFT.sol";

contract TestEnumerableNFT is Test {
    EnumerableNFT nft;
    address alice;
    address bob;
    address carol;

    function setUp() public {
        nft = new EnumerableNFT();

        alice = makeAddr("alice");
        bob = makeAddr("bob");
        carol = makeAddr("carol");

        // Mint 20 tokens, 7 for Alice, 7 for Bob, 6 for Carol
        for (uint256 i = 0; i < 20; i++) {
            uint256 index = i % 3;
            if (index == 0) {
                vm.prank(alice);
                nft.mint();
            } else if (index == 1) {
                vm.prank(bob);
                nft.mint();
            } else {
                vm.prank(carol);
                nft.mint();
            }
        }
    }

    function test_Balances() external {
        assertEq(nft.balanceOf(alice), 7);
        assertEq(nft.balanceOf(bob), 7);
        assertEq(nft.balanceOf(carol), 6);
    }
}
