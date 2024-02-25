// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

uint256 constant TOKEN_LIMIT = 1000;

contract CappedNFT is ERC721, ERC2981 {
    error LimitReached();

    address owner;
    uint256 tokenSupply;
    
    constructor() ERC721("Capped NFT", "CNFT") {
        owner = _msgSender();
        _setDefaultRoyalty(owner, 250); // 250bp = 2.5%
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns(bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address to) external {
        if (tokenSupply > TOKEN_LIMIT - 1) {
            revert LimitReached();
        }
        uint256 tokenId = tokenSupply;
        tokenSupply++;
        _safeMint(to, tokenId);
    }

    // function burn(uint256 tokenId) external {
    //     if (tokenSupply == 0) {
    //         revert LimitReached();
    //     }

    //     tokenSupply--;
    //     _burn(tokenId);
    // }
}