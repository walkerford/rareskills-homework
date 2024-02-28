// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

uint256 constant TOKEN_LIMIT = 20;

contract EnumerableNFT is ERC721Enumerable, Ownable {
    error LimitReached();

    constructor() ERC721("Enumerable NFT", "ET") Ownable(msg.sender) {}

    function mint() external returns (uint256) {
        // Check token supply
        if (totalSupply() > TOKEN_LIMIT - 1) revert LimitReached();

        uint256 tokenId = totalSupply();
        _safeMint(msg.sender, tokenId);

        return tokenId;
    }
}

contract CheckPrime {
    EnumerableNFT nft;

    constructor(EnumerableNFT nft_) {
        nft = nft_;
    }

    function checkPrime(address owner) external {}
}
