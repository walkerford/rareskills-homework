// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "week3-5-uniswap/Factory.sol";
import "./TestToken.sol";

contract TestFactory is Test {
    Factory factory;
    Pair pair;

    TestToken tokenA;
    TestToken tokenB;

    uint256 constant INITIAL_TOKENS = 10_000e18;
    uint256 constant INITIAL_TOKEN0 = 1e18;
    uint256 constant INITIAL_TOKEN1 = 4e18;
    uint256 constant INITIAL_SHARES = 2e18; // sqrt(1e18*4e18)=2e18

    function setUp() public {
        vm.label(address(this), "TestPair");
        tokenA = new TestToken();
        tokenB = new TestToken();

        tokenA.mint(address(this), INITIAL_TOKENS);
        tokenB.mint(address(this), INITIAL_TOKENS);

        factory = new Factory();
    }

    function test_Factory() external {
        // Sort token addresses
        (address token0, address token1) = sortTokens(
            address(tokenA),
            address(tokenB)
        );

        // Predict contract address for Pair
        address pairAddress = predictAddress(
            address(factory),
            type(Pair).creationCode,
            token0,
            token1
        );

        // Create Pair
        pair = Pair(factory.createPair(token0, token1));

        // Validate
        assertEq(pairAddress, address(pair));
    }
}

/**
 * Predicts the generated address of a Pair contract.  Assumes that the two
 * token addresses will be passed in as arguments to the contructor.
 * @param owner Deployer of the contract
 * @param creationCode Code of the contract
 * @param arg1 Token A
 * @param arg2 Token B
 */
function predictAddress(
    address owner,
    bytes memory creationCode,
    address arg1,
    address arg2
) pure returns (address predicted) {
    bytes32 salt = keccak256(abi.encodePacked(arg1, arg2));
    predicted = address(
        uint160(
            uint256(
                keccak256(
                    abi.encodePacked(
                        bytes1(0xff),
                        address(owner),
                        salt,
                        keccak256(
                            abi.encodePacked(
                                creationCode,
                                abi.encode(arg1, arg2)
                            )
                        )
                    )
                )
            )
        )
    );
}

function sortTokens(
    address tokenA,
    address tokenB
) pure returns (address token0, address token1) {
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
}
