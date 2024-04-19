// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Democracy.sol";

contract DemocracyTest is Test {
    Democracy democracy;

    function setUp() external {
        democracy = new Democracy{value: 1 ether}();
    }

    function test_setUp() external {
        assertEq(address(democracy).balance, 1 ether);
    }

    function test_attack() external {
        //
    }

    function _checkSolved() internal {
        assertEq(address(democracy).balance, 0);
    }
}
