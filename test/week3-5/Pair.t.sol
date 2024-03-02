// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "solady/tokens/ERC20.sol";
import "../../../src/week3-5/Pair.sol";

contract TestPair is Test {
    Pair pair;
    Token token0;
    Token token1;

    uint256 constant INITIAL_TOKEN0 = 1e18;
    uint256 constant INITIAL_TOKEN1 = 4e18;
    uint256 constant INITIAL_SHARES = 2e18; // sqrt(1e18*4e18)=2e18

    function setUp() public {
        vm.label(address(this), "TestPair");
        token0 = new Token();
        token1 = new Token();

        token0.mint(address(this), INITIAL_TOKEN0);
        token1.mint(address(this), INITIAL_TOKEN1);

        pair = new Pair(address(token0), address(token1));
    }

    function test_Mint() public {
        // Transfer tokens to Pair contract
        token0.transfer(address(pair), INITIAL_TOKEN0);
        token1.transfer(address(pair), INITIAL_TOKEN1);

        assertEq(token0.balanceOf(address(pair)), INITIAL_TOKEN0);
        assertEq(token1.balanceOf(address(pair)), INITIAL_TOKEN1);

        // Expect transfer event for burning minimum shares
        vm.expectEmit(true, true, true, true, address(pair));
        emit ERC20.Transfer(
            address(0),
            address(0), // burned
            pair.MINIMUM_INITIAL_SHARES()
        );

        // Expect transfer event for initial shares (less minimum) to user
        vm.expectEmit(true, true, true, true, address(pair));
        emit ERC20.Transfer(
            address(0),
            address(this),
            INITIAL_SHARES - pair.MINIMUM_INITIAL_SHARES()
        );

        // Expect Sync event from updating balances
        vm.expectEmit(true, false, false, true, address(pair));
        emit Pair.Sync(uint112(INITIAL_TOKEN0), uint112(INITIAL_TOKEN1));

        // Expect Mint event from minting shares
        vm.expectEmit(true, true, false, true, address(pair));
        emit Pair.Mint(address(this), INITIAL_TOKEN0, INITIAL_TOKEN1);

        // Mint shares
        pair.mint(address(this));
    }
}

contract Token is ERC20 {
    function name() public pure override returns (string memory) {
        return "TestERC";
    }

    function symbol() public pure override returns (string memory) {
        return "TK";
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
