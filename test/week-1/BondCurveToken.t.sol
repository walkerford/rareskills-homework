// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BondCurveToken, BctInsufficientFunding} from "../../src/week-1/BondCurveToken.sol";

uint256 constant BCT_PURCHASE_AMOUNT_1 = 1e18;
uint256 constant BCT_PURCHASE_PRICE_1 = 0.5e18;

uint256 constant BCT_PURCHASE_AMOUNT_2 = 2e18;
uint256 constant BCT_PURCHASE_PRICE_2 = 4e18;

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
        uint256 priceInWei = token.getPriceInWei(BCT_PURCHASE_AMOUNT_1);
        assertEq(priceInWei, BCT_PURCHASE_PRICE_1);

        // Make purchase 1
        vm.prank(alice);
        token.purchase{value: priceInWei}(BCT_PURCHASE_AMOUNT_1);
        assertEq(token.balanceOf(alice), BCT_PURCHASE_AMOUNT_1);

        console.log("Purchase 2");

        // Get price 2
        priceInWei = token.getPriceInWei(BCT_PURCHASE_AMOUNT_2);
        assertEq(priceInWei, BCT_PURCHASE_PRICE_2);

        // Make purchase 2
        vm.prank(alice);
        token.purchase{value: priceInWei}(BCT_PURCHASE_AMOUNT_2);
        assertEq(token.balanceOf(alice), BCT_PURCHASE_AMOUNT_1 + BCT_PURCHASE_AMOUNT_2);

        // Test supply
        assertEq(token.totalSupply(), BCT_PURCHASE_AMOUNT_1 + BCT_PURCHASE_AMOUNT_2);
    }

    function test_RevertWhen_InsufficientPayment() external {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(BctInsufficientFunding.selector, BCT_PURCHASE_PRICE_1));
        
        // Send purchase without payment
        token.purchase{value: 0}(BCT_PURCHASE_AMOUNT_1);
    }
}
