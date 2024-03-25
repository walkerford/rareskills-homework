// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.24;

import "forge-std/console.sol";
import "./RewardToken.sol";
import "./LimitedNFT.sol";

uint256 constant SECONDS_PER_PERIOD = 60 * 60 * 24;
uint256 constant SECONDS_PER_BLOCK = 12;
uint256 constant BLOCKS_PER_PERIOD = SECONDS_PER_PERIOD / SECONDS_PER_BLOCK; // 60*60*24/12=7200
uint256 constant REWARDS_PER_PERIOD = 10e18;

contract Staking is IERC721Receiver {
    error NotAuthorized();
    error NoStake();
    error NotEnoughCredits();
    
    event Stake();
    event Unstake();

    // Q: Is this necessary?
    event Withdraw();

    // Q: Is this necesary?
    event Accumulate();

    struct StakedNft {
        address owner;
        uint256 lastUnpaidBlock;
        uint256 credits;
    }

    RewardToken public rewardToken;
    LimitedNFT nft;

    /// @notice State of each staked NFT
    mapping(uint256 tokenId => StakedNft) stakedNfts;

    constructor(LimitedNFT nft_) {
        rewardToken = new RewardToken();
        nft = nft_;
        nft.setApprovalForAll(address(this), true);
    }

    /*** EXTERNAL FUNCTIONS ***/

    /// @notice Stake an NFT
    function stake(uint256 tokenId) external {
        // Q: Should this be memory or storage?
        StakedNft memory stakedNft = StakedNft({
            owner: msg.sender,
            lastUnpaidBlock: block.number,
            credits: 0
        });

        // Save state
        stakedNfts[tokenId] = stakedNft;

        // Transfer nft
        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        emit Stake();
    }

    /// @notice Unstake an NFT
    function unstake(uint256 tokenId) external {
        // Validate sender is owner
        if (stakedNfts[tokenId].owner != msg.sender) revert NotAuthorized();

        _updateCredits(tokenId);

        // Mark nft as unstaked
        stakedNfts[tokenId].lastUnpaidBlock = 0;

        // Transfer
        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Unstake();
    }

    /// @notice Withdraw all rewards
    function withdraw(uint256 tokenId) external {
        _updateCredits(tokenId);
        _withdraw(tokenId, stakedNfts[tokenId].credits);
    }

    /// @notice Withdraw only a specified amount of rewards
    function withdraw(uint256 tokenId, uint256 amount) external {
        _updateCredits(tokenId);
        _withdraw(tokenId, amount);
    }

    /// @notice Shows the balance of rewards yet to be withdrawn (credits).
    function credits(uint256 tokenId) external returns (uint256) {
        _updateCredits(tokenId);
        return stakedNfts[tokenId].credits;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /*** PRIVATE FUNCTIONS ***/

    function _updateCredits(uint256 tokenId) private {
        StakedNft storage staked = stakedNfts[tokenId];

        // Return if not staked
        // A non-zero `lastUnpaidBlock` indicates that the nft is still actively staked
        if (staked.lastUnpaidBlock == 0) return;

        // Get blocks since last payment
        uint256 blocks = block.number - staked.lastUnpaidBlock;

        // Rewards are only released in groups by period
        if (blocks >= BLOCKS_PER_PERIOD) {
            // Get how many full periods have passed
            uint256 periods = blocks / BLOCKS_PER_PERIOD;

            // Compute rewards across all periods
            uint256 rewards = periods * REWARDS_PER_PERIOD;

            // Accumulate the rewards
            staked.credits += rewards;

            // Update the last paid block
            staked.lastUnpaidBlock =
                staked.lastUnpaidBlock +
                (periods * BLOCKS_PER_PERIOD);

            emit Accumulate();
        }
    }

    function _withdraw(uint256 tokenId, uint256 amount) private {
        StakedNft storage staked = stakedNfts[tokenId];

        // Validate owner
        if (staked.owner != msg.sender) revert NotAuthorized();

        // Validate amount
        if (amount > staked.credits) revert NotEnoughCredits();

        // Reduce credits
        staked.credits -= amount;

        // Mint rewards
        rewardToken.mint(staked.owner, amount);

        emit Withdraw();
    }
}
