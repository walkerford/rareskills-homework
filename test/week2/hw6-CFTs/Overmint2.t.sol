// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../../src/week2/hw6-CFTs/Overmint2.sol";
import "../../../src/week2/hw6-CFTs/Overmint2Attacker.sol";

contract TestOvermint2 is Test {
    Overmint2 nft;
    Overmint2Attacker attacker;

    function setUp() external {
        nft = new Overmint2();
        attacker = new Overmint2Attacker(nft);
    }

    function test_Mint() external {
        // Start the attack
        attacker.attack();

        // Test for success
        vm.prank(address(attacker));
        assertEq(nft.success(), true);
    }
}
