// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week6-7-static-analysis/echidna/dex1/test-dex1.sol";

contract TestDexTest is Test {
    TestDex testDex;
    address dexAddress;
    address player;

    // address testDexAddress;

    function setUp() public {
        testDex = new TestDex();
        dexAddress = testDex.dexAddress();
        player = address(testDex);

        console.log("setUp() player", player);
        console.log("setUp() dex", dexAddress);
    }

    function test_setUp() public {
        assertEq(testDex.token1().balanceOf(dexAddress), 100);
        assertEq(testDex.token2().balanceOf(dexAddress), 100);
        assertEq(testDex.token1().balanceOf(player), 10);
        assertEq(testDex.token2().balanceOf(player), 10);
    }

    function test_swap() public {
        console.log("test_swap()");
        testDex.swapA(10); // -1 compensates for input massages for echidna
        console.log("token1(player):", testDex.token1().balanceOf(player));
        console.log("token2(player):", testDex.token2().balanceOf(player));
        console.log("token1(dex):", testDex.token1().balanceOf(dexAddress));
        console.log("token2(dex):", testDex.token2().balanceOf(dexAddress));

        assertEq(testDex.token1().balanceOf(player), 0);
        assertEq(testDex.token2().balanceOf(player), 20);
        assertEq(testDex.token1().balanceOf(dexAddress), 110);
        assertEq(testDex.token2().balanceOf(dexAddress), 90);

        testDex.swapB(20);
        console.log("token1(player):", testDex.token1().balanceOf(player));
        console.log("token2(player):", testDex.token2().balanceOf(player));
        console.log("token1(dex):", testDex.token1().balanceOf(dexAddress));
        console.log("token2(dex):", testDex.token2().balanceOf(dexAddress));

        assertEq(testDex.token1().balanceOf(player), 24);
        assertEq(testDex.token2().balanceOf(player), 0);
        assertEq(testDex.token1().balanceOf(dexAddress), 86);
        assertEq(testDex.token2().balanceOf(dexAddress), 110);

        testDex.swapA(24);
        console.log("token1(player):", testDex.token1().balanceOf(player));
        console.log("token2(player):", testDex.token2().balanceOf(player));
        console.log("token1(dex):", testDex.token1().balanceOf(dexAddress));
        console.log("token2(dex):", testDex.token2().balanceOf(dexAddress));

        assertEq(testDex.token1().balanceOf(player), 0);
        assertEq(testDex.token2().balanceOf(player), 30);
        assertEq(testDex.token1().balanceOf(dexAddress), 110);
        assertEq(testDex.token2().balanceOf(dexAddress), 80);
    }
}
