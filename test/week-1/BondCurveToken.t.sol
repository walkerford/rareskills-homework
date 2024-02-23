// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../../src/week-1/BondCurveToken.sol";

uint256 constant TOKEN_AMOUNT_1 = 1e18;
uint256 constant TOKEN_PRICE_1 = 0.5e18;

uint256 constant TOKEN_AMOUNT_2 = 2e18;
uint256 constant TOKEN_PRICE_2 = 4e18;

uint256 constant SALE_AMOUNT_1_5 = 1.5e18;

contract BondCurveTokenTest is Test {
    BondCurveToken token;

    address payable alice;
    address payable bob;

    function setUp() external {
        alice = payable(makeAddr("alice"));
        vm.deal(alice, 10 ether);

        bob = payable(makeAddr("bob"));

        vm.prank(alice);
        token = new BondCurveToken(0);
    }

    function test_Purchases() external {
        // Get price 1
        console.log("Purchase 1");
        uint256 priceInWei = token.getBuyPriceInWei(TOKEN_AMOUNT_1);
        assertEq(priceInWei, TOKEN_PRICE_1);

        // Make purchase 1
        vm.prank(alice);
        token.buy{value: priceInWei}(TOKEN_AMOUNT_1);
        assertEq(token.balanceOf(alice), TOKEN_AMOUNT_1);

        console.log("Purchase 2");

        // Get price 2
        priceInWei = token.getBuyPriceInWei(TOKEN_AMOUNT_2);
        assertEq(priceInWei, TOKEN_PRICE_2);

        // Make purchase 2
        vm.prank(alice);
        token.buy{value: priceInWei}(TOKEN_AMOUNT_2);
        assertEq(token.balanceOf(alice), TOKEN_AMOUNT_1 + TOKEN_AMOUNT_2);

        // Test supply
        assertEq(token.totalSupply(), TOKEN_AMOUNT_1 + TOKEN_AMOUNT_2);
    }

    function test_RevertWhen_InsufficientPayment() external {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(
                BctInsufficientFunding.selector,
                TOKEN_PRICE_1,
                0
            )
        );

        // Buy without payment
        token.buy{value: 0}(TOKEN_AMOUNT_1);
    }

    function test_Sell() external {
        // Purchase
        uint256 priceInWei = token.getBuyPriceInWei(TOKEN_AMOUNT_2);
        vm.prank(alice);
        token.buy{value: priceInWei}(TOKEN_AMOUNT_2);

        assertEq(token.balanceOf(alice), TOKEN_AMOUNT_2);

        // Transfer to another user
        vm.prank(alice);
        token.transfer(bob, TOKEN_AMOUNT_2);

        assertEq(token.balanceOf(bob), TOKEN_AMOUNT_2);

        // Sell half
        vm.prank(bob);
        token.sell(TOKEN_AMOUNT_1);

        // Check token and ether balances
        assertEq(token.balanceOf(bob), TOKEN_AMOUNT_1);
        assertEq(bob.balance, SALE_AMOUNT_1_5);
    }
}
