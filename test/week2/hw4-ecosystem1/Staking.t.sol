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

        vm.prank(alice);
        tokenId1 = nft.mint{value: 1 ether}();

        vm.prank(alice);
        tokenId2 = nft.mint{value: 1 ether}();
    }

    function test_Staking() external {
        assertEq(nft.balanceOf(alice), 2);

        vm.prank(alice);
        nft.approve(address(staking), tokenId1);

        vm.prank(alice);
        staking.stake(tokenId1);

        assertEq(nft.balanceOf(address(staking)), 1);

        vm.prank(alice);
        staking.unstake(tokenId1);

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
}