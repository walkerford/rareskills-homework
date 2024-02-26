// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.24;

import "forge-std/console.sol";
import "./RewardToken.sol";
import "./LimitedNFT.sol";

error UnauthorizedUnstake();

contract Staking is IERC721Receiver {
    RewardToken rewardToken;
    LimitedNFT nft;
    mapping(uint256 => address) stakedNfts;

    constructor(LimitedNFT nft_) {
        rewardToken = new RewardToken();
        nft = nft_;
    }

    function stake(uint256 tokenId) external {
        stakedNfts[tokenId] = msg.sender;
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function unstake(uint256 tokenId) external {
        if (stakedNfts[tokenId] != msg.sender) revert UnauthorizedUnstake();

        nft.approve(address(this), tokenId);
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function withdraw() external {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
