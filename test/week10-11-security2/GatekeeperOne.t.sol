// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/GatekeeperOne.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne gatekeeper;

    function setUp() external {
        gatekeeper = new GatekeeperOne();
    }

    function test() external {
        new Knight(gatekeeper);
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(gatekeeper.entrant(), tx.origin);
    }
}
