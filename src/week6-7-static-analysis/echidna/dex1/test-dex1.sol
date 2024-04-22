// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./dex1.sol";

contract TestDex {
    Dex dex;
    address tokenAddress1;
    address tokenAddress2;

    constructor() {
        dex = new Dex();
        address dexAddress = address(dex);

        SwappableToken token1 = new SwappableToken(
            dexAddress,
            "Token 1",
            "TKN1",
            110
        );
        SwappableToken token2 = new SwappableToken(
            dexAddress,
            "Token 2",
            "TKN2",
            110
        );

        tokenAddress1 = address(token1);
        tokenAddress2 = address(token2);

        dex.setTokens(tokenAddress1, tokenAddress2);

        token1.approve(dexAddress, 100);
        token2.approve(dexAddress, 100);

        dex.addLiquidity(tokenAddress1, 100);
        dex.addLiquidity(tokenAddress2, 100);

        token1.transfer(address(0x10000), 10);
        token2.transfer(address(0x10000), 10);

        dex.renounceOwnership();
    }

    function swap(uint256 number) public {
        address tokenA;
        address tokenB;

        if (number % 2 == 0) {
            tokenA = tokenAddress1;
            tokenB = tokenAddress2;
        } else {
            tokenA = tokenAddress2;
            tokenB = tokenAddress1;
        }
        // uint256 value = SwappableToken(tokenA).balanceOf(msg.sender);
        uint256 value = 10;
        dex.approve(address(dex), value);

        dex.swap(tokenA, tokenB, value);
    }

    // function approve(uint256 amount) public {
    //     dex.approve(address(dex), amount);
    // }

    function echidna_validate_tokens() public view returns (bool) {
        address t1 = dex.token1();
        address t2 = dex.token2();
        return t1 == tokenAddress1 && t2 == tokenAddress2;
    }

    function echidna_test() public view returns (bool) {
        uint256 balance1 = ERC20(tokenAddress1).balanceOf(address(dex));
        uint256 balance2 = ERC20(tokenAddress2).balanceOf(address(dex));

        // return balance1 != 0 && balance2 != 0;
        // return balance1 == 100 && balance2 == 100;
        // return balance1 < 25 || balance2 < 25;
        return balance1 == 100 && balance2 == 100;
    }
}
