// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/RewardToken.sol";

contract RewardTokenTest is Test {
    RewardToken token;
    NftToStake nft;
    Depositoor depositor;
    RewardTokenAttacker attacker;

    address attackerWallet;

    function setUp() external {
        attackerWallet = makeAddr("attackerWallet");

        vm.prank(attackerWallet);
        attacker = new RewardTokenAttacker();

        nft = new NftToStake(address(attacker));
        depositor = new Depositoor(nft);
        token = new RewardToken(address(depositor));

        depositor.setRewardToken(token);
    }

    function test_setUp() external {
        // Validate non-zero token address
        assertGt(uint160(address(depositor.rewardToken())), 0);

        // Validate reward token address was registered
        assertEq(address(depositor.rewardToken()), address(token));

        // Validate initial token balance
        assertEq(token.balanceOf(address(depositor)), 100e18);
        assertEq(token.balanceOf(address(attacker)), 0);

        // Validate starting nonce
        assertEq(vm.getNonce(attackerWallet), 1);
    }

    function test_attack() external {
        // Initiate the attack
        vm.prank(attackerWallet);
        attacker.initiate(depositor);

        // Wait 10 days
        skip(10 days);

        // Claim rewards
        vm.prank(attackerWallet);
        attacker.claim();
    }

    function _checkSolved() internal {
        // Attacker has all the tokens
        assertEq(token.balanceOf(address(attacker)), 100e18);

        // Depositor has been drained
        assertEq(token.balanceOf(address(depositor)), 0);

        // Performed in only one transaction

        // Nonce counting doesn't actually work due to a bug in Foundry.
        // Methods don't increment the count.
        assertEq(vm.getNonce(attackerWallet), 2);
    }
}
