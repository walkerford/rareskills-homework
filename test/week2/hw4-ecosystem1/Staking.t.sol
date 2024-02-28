// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import "../../../src/week2/hw4-ecosystem1/Staking.sol";

bytes32 constant MERKLE_ROOT = 0x502aa9198af78897bef863c2590af7f5cc8373aa8afd21b12c92b9e7aea0d047;

contract TestStaking is Test {
    Staking staking;
    LimitedNFT nft;
    address alice;
    uint256 tokenId1;
    uint256 tokenId2;

    function setUp() external {
        nft = new LimitedNFT(MERKLE_ROOT);
        staking = new Staking(nft);
        alice = makeAddr("alice");
        vm.deal(alice, 2 ether);

        // Alice gets first nft
        vm.prank(alice);
        tokenId1 = nft.mint{value: 1 ether}();

        // Alice gets second nft
        vm.prank(alice);
        tokenId2 = nft.mint{value: 1 ether}();
    }

    function _stake(address owner, uint256 tokenId) private {
        vm.prank(owner);
        nft.approve(address(staking), tokenId);
        vm.prank(owner);
        staking.stake(tokenId);
    }

    function _unstake(address owner, uint256 tokenId) private {
        vm.prank(owner);
        staking.unstake(tokenId);
    }

    function test_StakingAndUnstaking() external {
        assertEq(nft.balanceOf(alice), 2);

        _stake(alice, tokenId1);

        assertEq(nft.balanceOf(address(staking)), 1);

        _unstake(alice, tokenId1);

        assertEq(nft.balanceOf(address(staking)), 0);
        assertEq(nft.balanceOf(alice), 2);
    }

    function test_RevertWhen_StakingUnauthorized() external {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InsufficientApproval.selector,
                address(staking),
                1
            )
        );
        vm.prank(alice);
        staking.stake(tokenId2);
    }

    function test_RewardsAccumulation() external {
        // Stake happens in block 1
        _stake(alice, tokenId1);

        // Advance a full period
        vm.roll(BLOCKS_PER_PERIOD + 1);

        // Test rewards balance
        uint256 credits = staking.credits(tokenId1);
        assertEq(credits, REWARDS_PER_PERIOD);

        // Withdraw rewards
        vm.prank(alice);
        staking.withdraw(tokenId1);
        assertEq(staking.rewardToken().balanceOf(alice), REWARDS_PER_PERIOD);

        // Should have no credits left
        credits = staking.credits(tokenId1);
        assertEq(credits, 0);

        // Advance partial period
        vm.roll((BLOCKS_PER_PERIOD * 2) - 10);

        // Should have no credits
        credits = staking.credits(tokenId1);
        assertEq(credits, 0);

        // Advance another period
        vm.roll((BLOCKS_PER_PERIOD * 2) + 1);

        // Should have another one period's worth of credits
        credits = staking.credits(tokenId1);
        assertEq(credits, REWARDS_PER_PERIOD);

        // Unstake
        vm.prank(alice);
        staking.unstake(tokenId1);

        // Advance another period
        vm.roll((BLOCKS_PER_PERIOD * 2) + 1);

        // Should not have accumulated more credits
        credits = staking.credits(tokenId1);
        assertEq(credits, REWARDS_PER_PERIOD);

        // Can still withdraw, even after unstaking
        vm.prank(alice);
        staking.withdraw(tokenId1);
        assertEq(
            staking.rewardToken().balanceOf(alice),
            REWARDS_PER_PERIOD * 2
        );
    }
}
