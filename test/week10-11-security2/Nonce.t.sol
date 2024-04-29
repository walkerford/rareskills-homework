// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract NonceTest is Test {
    Counter counter;

    function test() external {
        // Nonce is 1
        assertEq(vm.getNonce(address(this)), 1);

        // Deploy counter
        counter = new Counter();

        // Nonce is 2
        assertEq(vm.getNonce(address(this)), 2);

        // Call add
        counter.add();

        // Nonce is still 2, not 3
        assertEq(vm.getNonce(address(this)), 2);
    }
}

contract Counter {
    uint256 counter;

    function add() external {
        counter++;
    }
}
