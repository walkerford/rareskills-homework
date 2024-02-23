// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

uint256 constant MULT = 1e15;
uint256 constant PRICE_UNITS_ADJUSTMENT = 2e18;

error BctInsufficientFunding(uint256 amount);

contract BondCurveToken is ERC20 {
    constructor(uint256 amount) ERC20("BondCurveToken", "BCT") {
        _mint(msg.sender, amount);
    }

    function purchase(uint256 amount) external payable {
        console.log("purchase() amount:", amount / MULT, "msg.value", msg.value / MULT);
        uint256 priceInWei = this.getPriceInWei(amount);
        if (msg.value < priceInWei) {
            revert BctInsufficientFunding(priceInWei);
        }

        _mint(msg.sender, amount);
    }

    function getPriceInWei(uint256 amount) external view returns (uint256) {
        uint256 totalSupply = this.totalSupply();
        uint256 priceInWei = ((((totalSupply + amount) ** 2)) -
            (totalSupply ** 2)) / PRICE_UNITS_ADJUSTMENT;
        console.log("getPriceInWei() totalSupply:", totalSupply / MULT, "price:", priceInWei / MULT);
        return priceInWei;
    }
}
