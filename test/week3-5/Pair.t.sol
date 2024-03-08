// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "solady/tokens/ERC20.sol";
import "../../../src/week3-5/Pair.sol";

contract TestPair is Test {
    Pair pair;
    Token token0;
    Token token1;

    uint256 constant INITIAL_TOKENS = 10_000e18;
    uint256 constant INITIAL_TOKEN0 = 1e18;
    uint256 constant INITIAL_TOKEN1 = 4e18;
    uint256 constant INITIAL_SHARES = 2e18; // sqrt(1e18*4e18)=2e18

    function setUp() public {
        vm.label(address(this), "TestPair");
        token0 = new Token();
        token1 = new Token();

        token0.mint(address(this), INITIAL_TOKENS);
        token1.mint(address(this), INITIAL_TOKENS);

        pair = new Pair(address(token0), address(token1));
    }
    
    function _addLiquidity(uint256 tokenAmount0, uint256 tokenAmount1) private {
        token0.transfer(address(pair), tokenAmount0);
        token1.transfer(address(pair), tokenAmount1);
        pair.mint(address(this));
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

    function test_RevertsWhen_SwapWithoutSufficientLiquidity() public {
        console.log("test_RevertsWhen_SwapWithoutSufficientLiquidity()");
        uint256[4][7] memory swapTestCases = [
            [uint256(1e18), 5e18, 10e18, 1_662_497_915_624_478_906],
            [uint256(1e18), 10e18, 5e18, 453_305_446_940_074_565],
            [uint256(2e18), 5e18, 10e18, 2_851_015_155_847_869_602],
            [uint256(2e18), 10e18, 5e18, 831_248_957_812_239_453],
            [uint256(1e18), 10e18, 10e18, 906_610_893_880_149_131],
            [uint256(1e18), 100e18, 100e18, 987_158_034_397_061_298],
            [uint256(1e18), 1000e18, 1000e18, 996_006_981_039_903_216]
        ];
        for (uint256 i=0; i<swapTestCases.length; ++i) {
            setUp();
            uint256[4] memory swapTestCase = swapTestCases[i];
            uint256 swapAmount = swapTestCase[0];
            uint256 tokenAmount0 = swapTestCase[1];
            uint256 tokenAmount1 = swapTestCase[2];
            uint256 expectedOutputAmount = swapTestCase[3];
        
            _addLiquidity(tokenAmount0, tokenAmount1);
            token0.transfer(address(pair), swapAmount);
            
            // Expect failure
            vm.expectRevert(abi.encodeWithSelector(Pair.InvalidReserveInvariant.selector));
            pair.swap(0, expectedOutputAmount + 1, address(this), "");
            
            // Expect success
            pair.swap(0, expectedOutputAmount, address(this), "");
        }

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
