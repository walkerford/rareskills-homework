// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DamnValuableToken is ERC20 {
    // Decimals are set to 18 by default in `ERC20`
    constructor() ERC20("DamnValuableToken", "DVT") {
        _mint(msg.sender, 2 ** 256 - 1);
    }
}
