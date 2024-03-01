// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

contract Pair {
    ERC20 token0;
    ERC20 token1;

    constructor(address token0_, address token1_) {
        token0 = token0_;
        token1 = token1_;
    }
}