// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract NonceTest is Test {
    Counter counter;

    function test() external {
        address alice = makeAddr("alice");

        // Nonce is 0
        assertEq(vm.getNonce(alice), 0);

        // Deploy counter
        vm.prank(alice);
        counter = new Counter();

        // Nonce is 1
        assertEq(vm.getNonce(alice), 1);

        // Call add
        vm.prank(alice);
        counter.add();

        // Nonce is still 1, not 2
        assertEq(vm.getNonce(alice), 1);
    }
}

contract Counter {
    uint256 counter;

    function add() external {
        counter++;
    }
}
