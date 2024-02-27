// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../../src/week2/hw6-CFTs/Overmint1.sol";
import "../../../src/week2/hw6-CFTs/Overmint1Attacker.sol";

contract TestOvermint1 is Test {
    Overmint1 nft;
    Overmint1Attacker attacker;

    function setUp() external {
        nft = new Overmint1();
        attacker = new Overmint1Attacker(nft);
    }

    function test_Mint() external {
        attacker.attack();
        assertEq(nft.balanceOf(address(attacker)), 5);
    }
}
