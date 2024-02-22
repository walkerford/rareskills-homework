// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

uint256 constant MULT = 1e15;

error TokenInsufficientFunding(uint256 amount);

contract BondCurveToken is ERC20 {
    constructor(uint256 amount) ERC20("BondCurveToken", "BCT") {
        _mint(msg.sender, amount);
    }

    function purchase(uint256 amount) external payable {
        console.log("purchase() amount:", amount / MULT);
        uint256 price_ = this.price(amount);
        console.log("price:", price_ / MULT);
        console.log("msg.value", msg.value / MULT);
        if (msg.value < price_) {
            revert TokenInsufficientFunding(price_ / MULT);
        }

        _mint(msg.sender, amount);
    }

    function price(uint256 amount) external view returns (uint256) {
        uint256 totalSupply = this.totalSupply();
        console.log("price() totalSupply:", totalSupply / MULT);
        uint256 price_ = ((((totalSupply + amount) ** 2)) -
            (totalSupply ** 2)) / 2e18;
        return price_;
    }
}
