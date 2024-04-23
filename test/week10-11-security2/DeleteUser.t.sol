// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Democracy.sol";

import "week10-11-security2/DeleteUser.sol";

contract DeleteUserTest is Test {
    DeleteUser victim;
    Attacker attacker;

    function setUp() external {
        victim = new DeleteUser();
        victim.deposit{value: 1 ether}();
    }

    function test_setUp() external {
        assertEq(address(victim).balance, 1 ether);
    }

    function test_attack() external {
        _checkSolved();
    }

    function _checkSolved() internal {
        // Zero balance
        assertEq(address(victim).balance, 0);

        // Only one transaction
        assertEq(vm.getNonce(address(attacker)), 1);
    }
}
