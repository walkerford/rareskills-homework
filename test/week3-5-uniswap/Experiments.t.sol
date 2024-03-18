// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "week3-5-uniswap/Experiments.sol";

contract TestExperiments is Test {
    Experiments ex;

    function setUp() external {
        ex = new Experiments();
    }

    function test_showUint112() external view {
        console.log("uint112.max", type(uint112).max);
        console.log("2**112", 2 ** 112);
        int16 a = -1;
        bytes memory b = abi.encodePacked(a);
        console.logBytes(b);
    }
}
