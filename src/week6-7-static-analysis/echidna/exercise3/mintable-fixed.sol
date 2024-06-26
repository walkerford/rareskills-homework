// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./token3.sol";

contract MintableToken is Token {
    uint256 public totalMinted;
    uint256 public totalMintable;

    constructor(uint256 totalMintable_) {
        totalMintable = totalMintable_;
    }

    function mint(uint256 value) public onlyOwner {
        require(value + totalMinted < totalMintable);
        totalMinted += uint256(value);

        balances[msg.sender] += value;
    }
}
