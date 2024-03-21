// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Indicates a sanctioned `receiver`. Used in transfers.
 * @param receiver Address to which tokens are being transferred.
 */
error ERC20SanctionedReceiver(address receiver);

/**
 * @dev Indicates a sanctioned `sender`. Used in transfers.
 * @param sender Address to which tokens are being transferred.
 */
error ERC20SanctionedSender(address sender);

/**
 * @dev Indicates an address that is not allowed to perform sanctioner functions.
 * @param address_ Address attempting sanctioner function.
 */
error ERC20UnauthorizedSanctioner(address address_);

contract SanctionToken is ERC20 {
    address immutable sanctioner;
    mapping(address => bool) private _sanctioned;

    constructor(uint256 amount) ERC20("SanctionToken", "ST") {
        sanctioner = msg.sender;
        _mint(msg.sender, amount);
    }

    function ban(address sanctioned) public {
        if (msg.sender != sanctioner) {
            revert ERC20UnauthorizedSanctioner(msg.sender);
        }
        _sanctioned[sanctioned] = true;
    }

    function unban(address sanctioned) public {
        if (msg.sender != sanctioner) {
            revert ERC20UnauthorizedSanctioner(msg.sender);
        }
        _sanctioned[sanctioned] = false;
    }

    function isSanctioned(address sanctioned) public view returns (bool) {
        return _sanctioned[sanctioned];
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (_sanctioned[from]) {
            revert ERC20SanctionedSender(from);
        } else if (_sanctioned[to]) {
            revert ERC20SanctionedReceiver(to);
        }
        super._update(from, to, value);
    }
}
