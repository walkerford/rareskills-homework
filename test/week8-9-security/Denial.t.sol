// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week8-9-security/Denial.sol";
import "week8-9-security/DenialAttacker.sol";

contract DenialTest is Test {
    Denial denial;
    DenialAttacker attacker;

    uint256 constant initialDeposit = 0.001 ether;

    function setUp() external {
        denial = new Denial();
        vm.deal(address(denial), initialDeposit);

        attacker = new DenialAttacker(denial);
    }

    function test_setUp() external {
        assertEq(address(denial).balance, initialDeposit);
    }

    function test_attack() external {
        denial.setWithdrawPartner(address(attacker));

        vm.expectRevert();
        (bool result, ) = address(denial).call{gas: 1000000}(
            abi.encodeWithSignature("withdraw()")
        );
        assertTrue(result);
    }
}
