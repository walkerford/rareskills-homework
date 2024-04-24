// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./BondCurveToken.sol";

// Note: used for testing with Echidna
contract BondCurveTokenWrapper {
    error InsufficientSupply();
    error InsufficientMsgValue();
    error PotentialOverflowA();
    error PotentialOverflowB();

    BondCurveToken public token;

    constructor() {
        token = new BondCurveToken(0);
    }

    function getBuyPriceInWei(uint256 amount) public view returns (uint256) {
        // Validate input won't overflow

        // Make sure amount won't overflow when totalSupply is non-zero
        if (type(uint256).max - token.totalSupply() < amount) {
            revert PotentialOverflowA();
        }

        // Make sure amount won't overflow
        // Overflow happens when (amount + totalSupply)**2 > type(uint256).max
        // sqrt(2**256) == 340282366920938463463374607431768211456
        if (
            amount + token.totalSupply() >=
            340282366920938463463374607431768211456
        ) {
            revert PotentialOverflowB();
        }

        return token.getBuyPriceInWei(amount);
    }

    function getSellPriceInWei(uint256 amount) public view returns (uint256) {
        // Validate sufficient supply
        if (amount > token.totalSupply()) revert InsufficientSupply();

        return getSellPriceInWei(amount);
    }

    function buy(uint256 amount) external payable {
        // Validate sufficient msg.value
        uint256 price = getBuyPriceInWei(amount);
        console.log("amount", amount);
        console.log("price", price);
        console.log("msg.value", msg.value);
        if (msg.value < price) revert InsufficientMsgValue();

        token.buy{value: msg.value}(amount);
    }

    function sell(uint256 amount) external payable {
        // Validate sufficient supply
        uint256 balance = token.balanceOf(address(this));
        if (amount > balance) revert InsufficientSupply();

        token.sell(amount);
    }

    function echidna_valid_balance() public view returns (bool) {
        // Ether balance should never go to zero while still retaining tokens
        // The first token is free (0.5 rounds down to 0), so > 1 accounts for
        // that
        if (address(token).balance == 0 && token.totalSupply() > 1) {
            return false;
        }

        return true;
    }
}
