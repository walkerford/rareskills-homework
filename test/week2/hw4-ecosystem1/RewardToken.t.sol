// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../../src/week2/hw4-ecosystem1/RewardToken.sol";

uint256 constant INITIAL_MINT = 1000;

contract TestRewardToken is Test {
    RewardToken token;

    function setUp() external {
        token = new RewardToken();
    }

    function test_Minting() external {
        token.mint(address(this), INITIAL_MINT);
        assertEq(token.balanceOf(address(this)), INITIAL_MINT);
    }
    
}