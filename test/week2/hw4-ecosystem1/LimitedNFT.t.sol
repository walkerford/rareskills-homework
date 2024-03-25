// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../../../src/week2/hw4-ecosystem1/LimitedNFT.sol";

bytes32 constant MERKLE_ROOT = 0x502aa9198af78897bef863c2590af7f5cc8373aa8afd21b12c92b9e7aea0d047;
bytes32 constant MERKLE_PROOF = 0xebf09d18ef212432cfa2e714503e8710a4032aa6d15b222f8880dd796ec2e957;
address constant ALICE = 0x1111111111111111111111111111111111111111;

// Slot 10 is the slot for the totalSupply variable.
// To find this out, compile with the following, then search for "tokenSupplY" in the json build artifact:
// ``` forge build --extra-output storageLayout ```
bytes32 constant TOTAL_SUPPLY_SLOT = bytes32(uint256(10));

contract TestLimitedNFT is Test {
    LimitedNFT nft;

    function setUp() public {
        // alice = makeAddr("alice");

        // Give user ether
        vm.deal(ALICE, 3 ether);

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

    function test_ExpectsRevert_mint_TooMuch() external {
        // Force totalSupply to be full
        vm.store(address(nft), TOTAL_SUPPLY_SLOT, bytes32(TOKEN_LIMIT));

        vm.expectRevert(abi.encodeWithSelector(LimitedNFT.LimitReached.selector));
        nft.mint{value: PRICE_NORMAL}();
    }

    function test_ExpectsRevert_mint_WrongPrice() external {
        vm.expectRevert(abi.encodeWithSelector(LimitedNFT.WrongPrice.selector));
        nft.mint{value: PRICE_DISCOUNTED}();
    }

    function test_DiscountedMint() external {
        // Create merkle proof
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = MERKLE_PROOF;

        // Mint discounted
        vm.prank(ALICE);
        nft.mintDiscounted{value: PRICE_DISCOUNTED}(proof, 0);

        // Validate mint (Alice starts with 1, but ends with 2)
        assertEq(nft.balanceOf(ALICE), 2);
    }

    function test_ExpectsRevert_DiscountedMintWrongPrice() external {
        // Create merkle proof
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = MERKLE_PROOF;

        // Mint discounted
        vm.expectRevert(abi.encodeWithSelector(LimitedNFT.WrongPrice.selector));
        vm.prank(ALICE);
        nft.mintDiscounted{value: PRICE_DISCOUNTED-1}(proof, 0);
    }

    function test_ExpectsRevert_DicountedMintBadMerkle() external {
        bytes32[] memory proof = new bytes32[](1);
        
        vm.expectRevert(abi.encodeWithSelector(LimitedNFT.BadProof.selector));
        vm.prank(ALICE);
        nft.mintDiscounted{value: PRICE_DISCOUNTED}(proof, 0);
    }

    function test_ExpectsRevert_DicountedMintAlreadyUsed() external {
        // Create merkle proof
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = MERKLE_PROOF;

        // Mint discounted
        vm.prank(ALICE);
        nft.mintDiscounted{value: PRICE_DISCOUNTED}(proof, 0);

        // Try again
        vm.expectRevert(abi.encodeWithSelector(LimitedNFT.DiscountUsed.selector));
        vm.prank(ALICE);
        nft.mintDiscounted{value: PRICE_DISCOUNTED}(proof, 0);
    }
 
    function test_Royalty() external {
        // Send purchase price of 1000, contract has 2.5% royalty, so 25 expected.
        (address royaltyReceiver, uint256 royaltyFraction) = nft.royaltyInfo(
            0,
            1000
        );
        assertEq(royaltyReceiver, ALICE);
        assertEq(royaltyFraction, 25);
    }

    function test_Withdraw() external {
        uint256 aliceStaringBalance = ALICE.balance;
        uint256 nftStartingBalance = address(nft).balance;

        // Withdraw ether
        vm.prank(ALICE);
        nft.withdraw(1 ether);

        // Validate ending balances
        assertEq(ALICE.balance, aliceStaringBalance + 1 ether);
        assertEq(address(nft).balance, nftStartingBalance - 1 ether);
    }

    function test_ExpectsRevert_withdraw_TooMuch() external {
        // uint256 aliceStaringBalance = ALICE.balance;
        uint256 nftStartingBalance = address(nft).balance;
        uint256 withdrawlAmount = nftStartingBalance + 1;

        // Withdraw too much ether
        vm.expectRevert(abi.encodeWithSelector(LimitedNFT.InsufficientBalance.selector, withdrawlAmount, nftStartingBalance));
        vm.prank(ALICE);
        nft.withdraw(withdrawlAmount);
    }

    function test_supportsInterface() external {
        assertEq(nft.supportsInterface(0), false);
        nft.supportsInterface(type(IERC165).interfaceId);
        nft.supportsInterface(type(IERC2981).interfaceId);
    }
}
