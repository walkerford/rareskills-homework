// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AdminToken is ERC20 {
    address admin;

    constructor(uint256 amount) ERC20("AdminToken", "AT") {
        admin = msg.sender;
        _mint(msg.sender, amount);
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        if (spender == admin) {
            return type(uint256).max;
        } else {
            return super.allowance(owner, spender);
        }
    }
}
