// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./dex1.sol";

contract TestDex {
    Dex public dex;
    address public dexAddress;
    address public tokenAddress1;
    address public tokenAddress2;
    SwappableToken public token1;
    SwappableToken public token2;
    address player;

    constructor() {
        dex = new Dex();
        dexAddress = address(dex);

        player = address(this);

        token1 = new SwappableToken(dexAddress, "Token 1", "TKN1", 110);
        token2 = new SwappableToken(dexAddress, "Token 2", "TKN2", 110);

        tokenAddress1 = address(token1);
        tokenAddress2 = address(token2);

        dex.setTokens(tokenAddress1, tokenAddress2);

        token1.approve(dexAddress, 100);
        token2.approve(dexAddress, 100);

        dex.addLiquidity(tokenAddress1, 100);
        dex.addLiquidity(tokenAddress2, 100);

        token1.transfer(player, 10);
        token2.transfer(player, 10);

        dex.renounceOwnership();
    }

    // Built for echidna to fuzz fromAmount, so unit tests should consider this
    function swapA(uint256 fromAmount) public {
        address from;
        address to;

        from = tokenAddress1;
        to = tokenAddress2;

        // Don't exceed player's balance
        // Let zeros pass through
        if (fromAmount != 0) {
            // Subtracting/Adding 1 so the range will include the players
            // balance, but not 0
            fromAmount =
                ((fromAmount - 1) % SwappableToken(from).balanceOf(player)) +
                1;
        }

        // Don't exceed bank's balance
        fromAmount = _getMaxSwap(fromAmount, from, to);

        dex.approve(dexAddress, fromAmount);
        dex.swap(from, to, fromAmount);
    }

    function swapB(uint256 fromAmount) public {
        address from;
        address to;

        from = tokenAddress2;
        to = tokenAddress1;

        // Don't exceed player's balance
        // Let zeros pass through
        if (fromAmount != 0) {
            // Subtracting/Adding 1 so the range will include the players
            // balance, but not 0
            fromAmount =
                ((fromAmount - 1) % SwappableToken(from).balanceOf(player)) +
                1;
        }

        // Don't exceed bank's balance
        fromAmount = _getMaxSwap(fromAmount, from, to);

        dex.approve(dexAddress, fromAmount);
        dex.swap(from, to, fromAmount);
    }

    // Makes sure the given swap won't overdraw the bank
    function _getMaxSwap(
        uint256 fromAmount,
        address from,
        address to
    ) internal view returns (uint256) {
        // Get quote
        uint256 toAmount = dex.getSwapfromAmount(from, to, fromAmount);

        // Get bank balance
        uint256 dexBalance = SwappableToken(to).balanceOf(dexAddress);

        // Make sure bank balance isn't exceeded
        if (toAmount > dexBalance) {
            // This formula is the inverse of the dex's price function.
            fromAmount =
                (dexBalance * IERC20(to).balanceOf(address(dex))) /
                IERC20(from).balanceOf(address(dex));
        }

        return fromAmount;
    }

    function echidna_test() public view returns (bool) {
        uint256 balance1 = ERC20(tokenAddress1).balanceOf(dexAddress);
        uint256 balance2 = ERC20(tokenAddress2).balanceOf(dexAddress);
        return balance1 > 0 && balance2 > 0;
    }
}
