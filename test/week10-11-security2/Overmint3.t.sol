// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Overmint3.sol";

contract Overmint3Test is Test {
    Overmint3 vault;
    Attacker attacker;
    address player;

    function setUp() external {
        vault = new Overmint3();
        player = makeAddr("player");
    }

    function test() external {
        vm.prank(player);
        attacker = new Attacker(vault, player);

        _checkSolved();
    }

    function _checkSolved() internal {
        // Only used one transaction
        assertEq(vm.getNonce(player), 1);

        // Has 5 NFTs
        assertEq(vault.balanceOf(player), 5);
    }
}
