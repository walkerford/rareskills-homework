// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../../../src/week2/hw4-ecosystem1/LimitedNFT.sol";

bytes32 constant MERKLE_ROOT = 0x502aa9198af78897bef863c2590af7f5cc8373aa8afd21b12c92b9e7aea0d047;
bytes32 constant MERKLE_PROOF = 0xebf09d18ef212432cfa2e714503e8710a4032aa6d15b222f8880dd796ec2e957;
address constant ALICE = 0x1111111111111111111111111111111111111111;

contract TestLimitedNFT is Test{
    LimitedNFT nft;

    function setUp() public {
        // alice = makeAddr("alice");

        // Give user ether
        vm.deal(ALICE, 1.5 ether);

        // Create contract
        vm.prank(ALICE);
        nft = new LimitedNFT(MERKLE_ROOT);
        
        // Mint nft using normal minting
        vm.prank(ALICE);
        nft.mint{value: 1 ether}();
    }

    function test_StartingBalance() external {
        // Should start out with 1 nft minted to alice
        assertEq(nft.balanceOf(ALICE), 1);
    }

    function test_DiscountedMint() external {
        // Create merkle proof
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = MERKLE_PROOF;

        // Mint discounted
        vm.prank(ALICE);
        nft.mintDicounted{value: PRICE_DISCOUNTED}(proof, 0);

        // Validate mint (Alice starts with 1, but ends with 2)
        assertEq(nft.balanceOf(ALICE), 2);
    }

    function test_Royalty() external {
        // Send purchase price of 1000, contract has 2.5% royalty, so 25 expected.
        (address royaltyReceiver, uint256 royaltyFraction) = nft.royaltyInfo(0, 1000);
        assertEq(royaltyReceiver, ALICE);
        assertEq(royaltyFraction, 25);
    }

    function test_Withdraw() external {
        // Validate starting balances
        assertEq(ALICE.balance, 0.5 ether);
        assertEq(address(nft).balance, 1 ether);
        
        // Withdraw ether
        vm.prank(ALICE);
        nft.withdraw(1 ether);

        // Validate ending balances
        assertEq(ALICE.balance, 1.5 ether);
        assertEq(address(nft).balance, 0);
    }
}