// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

uint256 constant TOKEN_LIMIT = 1000;
uint256 constant PRICE_NORMAL = 1e18;
uint256 constant PRICE_DISCOUNTED = PRICE_NORMAL / 2;

contract LimitedNFT is ERC721, ERC2981 {
    using BitMaps for BitMaps.BitMap;
    
    error LimitReached();
    error WrongPrice();
    error BadProof();
    error DiscountUsed();

    address owner;
    uint256 tokenSupply;
    bytes32 merkleRoot;
    BitMaps.BitMap bitMap;
    
    constructor(bytes32 merkleRoot_) ERC721("Limited NFT", "LT") {
        owner = _msgSender();
        merkleRoot = merkleRoot_;
        _setDefaultRoyalty(owner, 250); // 250bp = 2.5%

        // Set bitmap to all 1's, so that clearing the bit (in minting) is cheaper for user
        bitMap._data[0] = type(uint256).max;
        bitMap._data[1] = type(uint256).max;
        bitMap._data[2] = type(uint256).max;
        bitMap._data[3] = type(uint256).max;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns(bool) {
        return super.supportsInterface(interfaceId);
    }

    function mintDicounted(bytes32[] calldata merkleProof, uint256 index) external payable {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_msgSender(), index))));
        bool verified = MerkleProof.verify(merkleProof, merkleRoot, leaf);

        // Validate merkle proof
        if (!verified) revert BadProof();

        // Validate discount is available
        if (!bitMap.get(index)) revert DiscountUsed();
        
        // Validate price
        if (msg.value != PRICE_DISCOUNTED) revert WrongPrice();

        bitMap.unset(index);

        _mint();
    }

    function mint() external payable {
        if (msg.value != PRICE_NORMAL) revert WrongPrice();

        _mint();
    }

    function _mint() private {
        // Check token supply
        if (tokenSupply > TOKEN_LIMIT - 1) revert LimitReached();

        uint256 tokenId = tokenSupply;
        tokenSupply++;
        _safeMint(_msgSender(), tokenId);
    }
}