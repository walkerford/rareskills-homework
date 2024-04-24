// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week6-7-static-analysis/echidna/bond-curve-token/BondCurveTokenWrapper.sol";

contract BondCurveTokenWrapperTest is Test {
    BondCurveTokenWrapper tokenZero;

    function setUp() public {
        tokenZero = new BondCurveTokenWrapper();
    }

    function test_catches_overflow() public {
        // Tests the overflow catch that only accounts for amount (no previous buys)

        vm.expectRevert(
            abi.encodeWithSelector(
                BondCurveTokenWrapper.PotentialOverflowB.selector
            )
        );

        // Buy a bunch
        uint256 amount = 340975073277802597707057906213392149944;
        tokenZero.buy(amount);
    }

    function test_catches_overflow2() public {
        // Tests the overflow catch that includes the totalSupply in the calucation (includes a previous buy)

        // First buy one token
        uint256 amount = 1;
        uint256 price = tokenZero.getBuyPriceInWei(amount);
        tokenZero.buy{value: price}(amount);

        vm.expectRevert(
            abi.encodeWithSelector(
                BondCurveTokenWrapper.PotentialOverflowB.selector
            )
        );

        // Second buy a bunch
        amount = 340282366920938463463374607431768211455;
        price = tokenZero.getBuyPriceInWei(amount);

        vm.expectRevert(
            abi.encodeWithSelector(
                BondCurveTokenWrapper.PotentialOverflowB.selector
            )
        );

        tokenZero.buy{value: price}(amount);
    }

    function test_catches_overflow3() public {
        // Tests the overflow catch that includes the totalSupply in the calucation (includes a previous buy)

        // First, buy one token
        uint256 amount = 2;
        uint256 price = tokenZero.getBuyPriceInWei(amount);
        tokenZero.buy{value: price}(amount);

        // Second, buy a bunch

        vm.expectRevert(
            abi.encodeWithSelector(
                BondCurveTokenWrapper.PotentialOverflowA.selector
            )
        );

        amount = 115792089237316195423570985008687907853269984665640564039457584007913129639934;
        price = tokenZero.getBuyPriceInWei(amount);

        vm.expectRevert(
            abi.encodeWithSelector(
                BondCurveTokenWrapper.PotentialOverflowA.selector
            )
        );

        tokenZero.buy{value: price}(amount);
    }

    function test_buy1() public {
        tokenZero.buy(1); // the first token is free
        assertEq(address(tokenZero.token()).balance, 0);
        assertEq(tokenZero.token().totalSupply(), 1);
    }

    function test_buy2() public {
        tokenZero.buy{value: 2}(2); // the first two tokens costs 2
        assertEq(address(tokenZero.token()).balance, 2);
        assertEq(tokenZero.token().totalSupply(), 2);

        tokenZero.buy{value: 6}(2); // the second two tokens costs 6
        assertEq(address(tokenZero.token()).balance, 8);
        assertEq(tokenZero.token().totalSupply(), 4);
    }

    // function test_pricing() public view {
    //     for (uint256 i; i <= 10; i += 1) {
    //         console.log("i", i, tokenZero.getBuyPriceInWei(i));
    //     }
    // }
}
