// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Forwarder.sol";

contract ForwarderTest is Test {
    Forwarder forwarder;
    Wallet wallet;
    Attacker attacker;

    function setUp() public {
        // Deploy forwarder
        forwarder = new Forwarder();

        // Deploy Wallet with 1 ether
        wallet = new Wallet{value: 1 ether}(address(forwarder));

        // Deploy attacker
        attacker = new Attacker(forwarder, wallet);
    }

    function test_setUp() public {
        assertEq(address(wallet).balance, 1 ether);
        assertEq(address(attacker).balance, 0);
    }

    function test_attack() public {
        attacker.attack();
        _checkCompleted();
    }

    function _checkCompleted() internal {
        assertEq(address(wallet).balance, 0);
        assertEq(address(attacker).balance, 1 ether);
    }
}
