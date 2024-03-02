// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "solady/tokens/ERC20.sol";
import "../../../src/week3-5/Pair.sol";

contract TestPair is Test {
    Pair pair;

    function setUp() public {
        pair = new Pair(address(0x1), address(0x2));
    }

    function test_Update() public {
        // pair.update(0, 0, 0, 0);
    }
}

// contract TestPairUpdate is Pair {
//     constructor(address a1, address a2) Pair(a1, a2) {}

//     function update(
//         uint256 balance0,
//         uint256 balance1,
//         uint256 reserve0,
//         uint256 reserve1
//     ) public {
//         _update(balance0, balance1, reserve0, reserve1);
//     }
// }
