// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../../../src/week2/hw5-ecosystem2/EnumerableNFT.sol";
import "../../../src/week2/hw5-ecosystem2/CheckPrime.sol";

contract TestEnumerableNFT is Test {
    EnumerableNFT nft;
    CheckPrime checkPrime;
    address alice;
    address bob;
    address carol;

    function setUp() public {
        nft = new EnumerableNFT();
        checkPrime = new CheckPrime(nft);

        alice = makeAddr("alice");
        bob = makeAddr("bob");
        carol = makeAddr("carol");

        // Mint 20 tokens, 7 for Alice, 7 for Bob, 6 for Carol
        for (uint256 i = 0; i < 20; i++) {
            uint256 index = i % 3;
            if (index == 0) {
                vm.prank(alice);
                nft.mint();
            } else if (index == 1) {
                vm.prank(bob);
                nft.mint();
            } else {
                vm.prank(carol);
                nft.mint();
            }
        }
    }

    function test_Balances() external {
        assertEq(nft.balanceOf(alice), 7);
        assertEq(nft.balanceOf(bob), 7);
        assertEq(nft.balanceOf(carol), 6);
    }

    function test_Primes() external {
        assertEq(checkPrime.isPrime(0), false);
        assertEq(checkPrime.isPrime(1), false);
        assertEq(checkPrime.isPrime(2), true);
        assertEq(checkPrime.isPrime(3), true);
        assertEq(checkPrime.isPrime(4), false);
        assertEq(checkPrime.isPrime(5), true);
        assertEq(checkPrime.isPrime(6), false);
        assertEq(checkPrime.isPrime(7), true);
        assertEq(checkPrime.isPrime(8), false);
        assertEq(checkPrime.isPrime(9), false);
        assertEq(checkPrime.isPrime(10), false);
        assertEq(checkPrime.isPrime(11), true);
        assertEq(checkPrime.isPrime(12), false);
        assertEq(checkPrime.isPrime(13), true);
        assertEq(checkPrime.isPrime(14), false);
        assertEq(checkPrime.isPrime(15), false);
        assertEq(checkPrime.isPrime(16), false);
        assertEq(checkPrime.isPrime(17), true);
        assertEq(checkPrime.isPrime(18), false);
        assertEq(checkPrime.isPrime(19), true);
        assertEq(checkPrime.isPrime(20), false);
    }

    function test_MintedPrimes() external {
        assertEq(checkPrime.check(alice), 1);
        assertEq(checkPrime.check(bob), 3);
        assertEq(checkPrime.check(carol), 4);
    }
}