// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";

contract TestExperiments is Test {
    function setUp() external {}

    function test_showUint112() external view {
        console.log("uint112.max", type(uint112).max);
        console.log("2**112", 2 ** 112);
        int16 a = -1;
        bytes memory b = abi.encodePacked(a);
        console.logBytes(b);
    }
}
