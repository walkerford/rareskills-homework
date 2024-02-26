// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.24;

import "forge-std/console.sol";
import "./RewardToken.sol";
import "./LimitedNFT.sol";

error UnauthorizedUnstake();

uint256 constant UNLOCK_PERIOD_IN_BLOCKS = 10;
uint256 constant SECONDS_PER_BLOCK = 12;
uint256 constant SECONDS_PER_PERIOD = 60 * 60 * 24;
uint256 constant BLOCKS_PER_PERIOD = SECONDS_PER_PERIOD / SECONDS_PER_BLOCK;
uint256 constant REWARDS_PER_PERIOD = 10 ether;
uint256 constant REWARDS_PER_BLOCK = REWARDS_PER_PERIOD / BLOCKS_PER_PERIOD;


contract Staking is IERC721Receiver {
    struct StakedNft {
        address owner;
        uint256 lastPaidBlock;
    }
    
    /// @notice RewardToken contract
    RewardToken rewardToken;

    /// @notice Nft contract
    LimitedNFT nft;

    /// @notice State of each staked NFT
    mapping(uint256 => StakedNft) stakedNfts;

    constructor(LimitedNFT nft_) {
        rewardToken = new RewardToken();
        nft = nft_;
    }

    function stake(uint256 tokenId) external {
        // Q: Should this be memory or storage?
        StakedNft memory stakedNft = StakedNft({owner: msg.sender, lastPaidBlock: block.number});
        stakedNfts[tokenId] = stakedNft;
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function unstake(uint256 tokenId) external {
        // Validate sender is owner
        if (stakedNfts[tokenId].owner != msg.sender) revert UnauthorizedUnstake();

        nft.approve(address(this), tokenId);
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function withdraw() external {

    }

    /// @notice Check the balance of rewards yet to be withdrawn.  Due to unlock period,
    /// there may be more rewards accrued than are avaiable to withdraw.
    function rewardsBalanceOf(uint256 tokenId) external view returns(uint256) {
        uint256 blocks;
        unchecked {
            // lastPaidBlock is updated by contract logic and block numbers only advance
            blocks = block.number - stakedNfts[tokenId].lastPaidBlock;
        }
        uint256 rewards = blocks * REWARDS_PER_BLOCK;
        return rewards;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
