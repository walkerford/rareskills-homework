// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Pair.sol";

contract Factory {
    error IdenticalAddresses();
    error InvalidAddress();
    error PreexistingPair();

    event PairCreated(
        address token0,
        address token1,
        address pair,
        uint256 index
    );

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (Pair pair) {
        // Can't be the same address
        if (tokenA == tokenB) {
            revert IdenticalAddresses();
        }

        // Set the token order
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        // Can't be zero address
        if (token0 == address(0)) {
            revert InvalidAddress();
        }

        // Pair must not already exist
        if (getPair[token0][token1] != address(0)) {
            revert PreexistingPair();
        }

        // Create Pair
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        pair = new Pair{salt: salt}(token0, token1);

        // Set up getPair
        getPair[token0][token1] = address(pair);
        getPair[token1][token0] = address(pair);
        allPairs.push(address(pair));

        // Event
        emit PairCreated(token0, token1, address(pair), allPairs.length);
    }
}
