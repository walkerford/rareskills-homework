// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {CappedNFT} from "../../src/week-2/hw4-ecosystem1/CappedNFT.sol";

contract TestCappedNFT is Test{
    address alice;

    CappedNFT token;

    constructor() {}

    function setUp() public {
        alice = makeAddr("alice");
        token = new CappedNFT();
    }

    function test_Mint() external {
        token.mint(alice);
        assertEq(token.balanceOf(alice), 1);
    }
}