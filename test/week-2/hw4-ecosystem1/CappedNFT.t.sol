// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../../../src/week-2/hw4-ecosystem1/CappedNFT.sol";

bytes32 constant MERKLE_ROOT = 0x502aa9198af78897bef863c2590af7f5cc8373aa8afd21b12c92b9e7aea0d047;
bytes32 constant MERKLE_PROOF = 0xebf09d18ef212432cfa2e714503e8710a4032aa6d15b222f8880dd796ec2e957;
address constant ALICE = 0x1111111111111111111111111111111111111111;

contract TestCappedNFT is Test{
    CappedNFT token;

    function setUp() public {
        // alice = makeAddr("alice");

        // Give user ether
        vm.deal(ALICE, 1.5 ether);

        // Create contract
        vm.prank(ALICE);
        token = new CappedNFT(MERKLE_ROOT);
        
        // Mint token using normal minting
        vm.prank(ALICE);
        token.mint{value: 1 ether}();
    }

    function test_Balance() external {
        assertEq(token.balanceOf(ALICE), 1);
    }

    function test_Discount() external {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = MERKLE_PROOF;
        vm.prank(ALICE);
        token.mintDicounted{value: PRICE_DISCOUNTED}(proof, 0);
        assertEq(token.balanceOf(ALICE), 2);
    }

    function test_Royalty() external {
        // Send purchase price of 1000, contract has 2.5% royalty, so 25 expected.
        (address royaltyReceiver, uint256 royaltyFraction) = token.royaltyInfo(0, 1000);
        assertEq(royaltyReceiver, ALICE);
        assertEq(royaltyFraction, 25);
    }
}