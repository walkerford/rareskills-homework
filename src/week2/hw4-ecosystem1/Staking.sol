// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.24;

import {console} from "forge-std/console.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./RewardToken.sol";
import "./LimitedNFT.sol";

contract Staking is IERC721Receiver {
    RewardToken rewardToken;
    LimitedNFT nft;
    mapping(uint256 => address) stakedNfts;

    constructor(LimitedNFT nft_) {
        rewardToken = new RewardToken();
        nft = nft_;
        console.log("test");
    }

    function stake(uint256 tokenId) external {
        stakedNfts[tokenId] = msg.sender;
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function unstake(uint256 tokenId) external {

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