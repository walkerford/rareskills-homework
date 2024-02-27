// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Address.sol";

uint256 constant TOKEN_LIMIT = 1000;
uint256 constant PRICE_NORMAL = 1e18;
uint256 constant PRICE_DISCOUNTED = PRICE_NORMAL / 2;

error InsufficientBalance(uint256 amount, uint256 balance);

contract LimitedNFT is ERC721, ERC2981, Ownable2Step {
    using BitMaps for BitMaps.BitMap;
    using Address for address;
    
    error LimitReached();
    error WrongPrice();
    error BadProof();
    error DiscountUsed();

    uint256 tokenSupply;
    bytes32 merkleRoot;
    BitMaps.BitMap bitMap;
    
    constructor(bytes32 merkleRoot_) ERC721("Limited NFT", "LT") Ownable(msg.sender) { 
        _setDefaultRoyalty(msg.sender, 250); // 250bp = 2.5%

        // The merkle tree contains all the addresses that area llowed to mint at a discount
        merkleRoot = merkleRoot_;

        // bitMap tracks which addresses have minted at a discount
        // Set bitmaps initially, so that the first minter doens't have to pay for the zero to non-zero change.
        // Inverted logic is used to save gas costs.  Set means unused and unset means used.
        bitMap._data[0] = type(uint256).max;
        bitMap._data[1] = type(uint256).max;
        bitMap._data[2] = type(uint256).max;
        bitMap._data[3] = type(uint256).max;
    }

    /// @notice Only those addresses included in the merkle tree can mint at a discount
    function mintDicounted(bytes32[] calldata merkleProof, uint256 index) external payable returns(uint256) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_msgSender(), index))));
        bool verified = MerkleProof.verify(merkleProof, merkleRoot, leaf);

        // Validate merkle proof
        if (!verified) revert BadProof();

        // Validate discount is available
        if (!bitMap.get(index)) revert DiscountUsed();
        
        // Validate price
        if (msg.value != PRICE_DISCOUNTED) revert WrongPrice();

        // Mark that discount is used
        bitMap.unset(index);

        return _mint();
    }

    /// @notice Anyone can mint at full price
    function mint() external payable returns(uint256) {
        if (msg.value != PRICE_NORMAL) revert WrongPrice();

        return _mint();
    }

    /// @notice Owner can withdraw ether from this contract
    function withdraw(uint256 amount) external onlyOwner {
        if (amount > address(this).balance) revert InsufficientBalance(amount, address(this).balance);
        Address.sendValue(payable(owner()), amount);
    }

    /*** Private Functions ***/

    function _mint() private returns(uint256) {
        // Check token supply
        if (tokenSupply > TOKEN_LIMIT - 1) revert LimitReached();

        uint256 tokenId = tokenSupply;
        tokenSupply++;
        _safeMint(_msgSender(), tokenId);

        return tokenId;
    }

    /*** View Functions ***/

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns(bool) {
        return super.supportsInterface(interfaceId);
    }
}