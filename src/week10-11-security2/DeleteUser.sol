// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;
import "forge-std/console.sol";

/**
 * This contract starts with 1 ether.
 * Your goal is to steal all the ether in the contract.
 *
 */

contract DeleteUser {
    error Unauthorized();
    error CallFailed();

    struct User {
        address addr;
        uint256 amount;
    }

    User[] private users;

    function deposit() external payable {
        users.push(User({addr: msg.sender, amount: msg.value}));
    }

    function withdraw(uint256 index) external {
        User storage user = users[index];
        if (user.addr != msg.sender) revert Unauthorized();
        uint256 amount = user.amount;

        user = users[users.length - 1];
        users.pop();

        // msg.sender.call{value: amount}("");
        (bool ok, ) = msg.sender.call{value: amount}("");
        if (!ok) revert CallFailed();
    }
}
