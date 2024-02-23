// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

uint256 constant MULT = 1e15;
uint256 constant PRICE_UNITS_ADJUSTMENT = 2e18;

error BctInsufficientFunding(uint256 price, uint256 available);

contract BondCurveToken is ERC20 {
    using Address for address payable;

    constructor(uint256 amount) ERC20("BondCurveToken", "BCT") {
        _mint(msg.sender, amount);
    }

    function getBuyPriceInWei(uint256 amount) external view returns (uint256) {
        uint256 totalSupply = this.totalSupply();
        uint256 priceInWei = ((((totalSupply + amount) ** 2)) -
            (totalSupply ** 2)) / PRICE_UNITS_ADJUSTMENT;
        console.log(
            "getBuyPriceInWei() totalSupply:",
            totalSupply / MULT,
            "price:",
            priceInWei / MULT
        );
        return priceInWei;
    }

    function getSellPriceInWei(uint256 amount) external view returns (uint256) {
        uint256 totalSupply = this.totalSupply();
        // Solidity underflow check will catch if amount is too large
        uint256 priceInWei = ((totalSupply ** 2) -
            ((totalSupply - amount) ** 2)) / PRICE_UNITS_ADJUSTMENT;
        console.log(
            "getSellPriceInWei() totalSupply:",
            totalSupply / MULT,
            "price:",
            priceInWei / MULT
        );
        return priceInWei;
    }

    function buy(uint256 amount) external payable {
        uint256 priceInWei = this.getBuyPriceInWei(amount);
        if (msg.value < priceInWei) {
            revert BctInsufficientFunding(priceInWei, msg.value);
        }

        _mint(msg.sender, amount);
    }

    function sell(uint256 amount) external payable {
        uint256 priceInWei = this.getSellPriceInWei(amount);
        if (priceInWei > address(this).balance) {
            revert BctInsufficientFunding(priceInWei, address(this).balance);
        }

        _burn(msg.sender, amount);
        payable(msg.sender).sendValue(priceInWei);
    }
}
