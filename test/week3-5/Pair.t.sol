// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC3156.sol";
import "solady/tokens/ERC20.sol";
import "../../../src/week3-5/Pair.sol";

contract TestPair is Test {
    Pair pair;
    Token token0;
    Token token1;

    uint256 constant INITIAL_TOKENS = 10_000e18;
    uint256 constant LOAN_AMOUNT = 5_000e18;
    uint256 constant LOAN_FEE = 15e18; // 0.3% of 5_000e18
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
        pair.mint(address(this), 0);
    }

    function test_Burn() public {
        uint256 amount0 = 3e18;
        uint256 amount1 = 3e18;

        // this is also the amount of tokens we exect back from each token contract
        uint256 expectedShares = 3e18 - MINIMUM_INITIAL_SHARES;

        _addLiquidity(amount0, amount1);

        ERC20(pair).transfer(address(pair), expectedShares);

        // Expect a burn of shares
        vm.expectEmit(true, true, true, true, address(pair));
        emit ERC20.Transfer(address(pair), address(0), expectedShares);

        // Expect a tranfer of token0 back to sender
        vm.expectEmit(true, true, true, true, address(token0));
        emit ERC20.Transfer(address(pair), address(this), expectedShares);

        // Expect a tranfer of token1 back to sender
        vm.expectEmit(true, true, true, true, address(token1));
        emit ERC20.Transfer(address(pair), address(this), expectedShares);

        // Expect reserves sync to the minimum inital shares
        vm.expectEmit(true, false, false, true, address(pair));
        emit Pair.Sync(
            uint112(MINIMUM_INITIAL_SHARES),
            uint112(MINIMUM_INITIAL_SHARES)
        );

        // Expect burn event
        vm.expectEmit(true, true, true, true, address(pair));
        emit Pair.Burn(
            address(this),
            expectedShares,
            expectedShares,
            address(this)
        );

        pair.burn(address(this));

        // This contract should hold no more shares
        assertEq(pair.balanceOf(address(this)), 0);

        // Pair contract should have a total supply equal to minimum shares
        assertEq(pair.totalSupply(), MINIMUM_INITIAL_SHARES);
        assertEq(token0.balanceOf(address(pair)), MINIMUM_INITIAL_SHARES);
        assertEq(token1.balanceOf(address(pair)), MINIMUM_INITIAL_SHARES);

        // Test contract should have all the tokens but the minimum shares
        uint256 totalSupply0 = token0.totalSupply();
        uint256 totalSupply1 = token1.totalSupply();
        assertEq(
            token0.balanceOf(address(this)),
            totalSupply0 - MINIMUM_INITIAL_SHARES
        );
        assertEq(
            token1.balanceOf(address(this)),
            totalSupply1 - MINIMUM_INITIAL_SHARES
        );
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
            MINIMUM_INITIAL_SHARES
        );

        // Expect transfer event for initial shares (less minimum) to user
        vm.expectEmit(true, true, true, true, address(pair));
        emit ERC20.Transfer(
            address(0),
            address(this),
            INITIAL_SHARES - MINIMUM_INITIAL_SHARES
        );

        // Expect Sync event from updating balances
        vm.expectEmit(true, false, false, true, address(pair));
        emit Pair.Sync(uint112(INITIAL_TOKEN0), uint112(INITIAL_TOKEN1));

        // Expect Mint event from minting shares
        vm.expectEmit(true, true, false, true, address(pair));
        emit Pair.Mint(address(this), INITIAL_TOKEN0, INITIAL_TOKEN1);

        // Mint shares
        pair.mint(address(this), 0);
    }

    function test_ExpectsRevert_MintShares() external {
        // Transfer tokens to Pair contract
        token0.transfer(address(pair), INITIAL_SHARES);
        token1.transfer(address(pair), INITIAL_SHARES);

        // Mint shares, but expect a revert since slippage is not met, because
        // minimum shares will be taken out
        vm.expectRevert(
            abi.encodeWithSelector(Pair.MintingSlippageNotMet.selector)
        );
        pair.mint(address(this), INITIAL_SHARES);
    }

    function test_SwapTestCases() public {
        uint256[4][7] memory testCases = [
            [uint256(1e18), 5e18, 10e18, 1_662_497_915_624_478_906],
            [uint256(1e18), 10e18, 5e18, 453_305_446_940_074_565],
            [uint256(2e18), 5e18, 10e18, 2_851_015_155_847_869_602],
            [uint256(2e18), 10e18, 5e18, 831_248_957_812_239_453],
            [uint256(1e18), 10e18, 10e18, 906_610_893_880_149_131],
            [uint256(1e18), 100e18, 100e18, 987_158_034_397_061_298],
            [uint256(1e18), 1000e18, 1000e18, 996_006_981_039_903_216]
        ];
        for (uint256 i = 0; i < testCases.length; ++i) {
            setUp();
            uint256[4] memory testCase = testCases[i];
            uint256 swapAmount = testCase[0];
            uint256 tokenAmount0 = testCase[1];
            uint256 tokenAmount1 = testCase[2];
            uint256 expectedOutputAmount = testCase[3];

            _addLiquidity(tokenAmount0, tokenAmount1);
            token0.transfer(address(pair), swapAmount);

            // Expect failure
            vm.expectRevert(
                abi.encodeWithSelector(Pair.InvalidReserveInvariant.selector)
            );
            pair.swap(0, expectedOutputAmount + 1, address(this));

            // Expect success
            pair.swap(0, expectedOutputAmount, address(this));
        }
    }

    function test_OptimisticTestCases() public {
        uint256[4][4] memory testCases = [
            [uint256(997_000_000_000_000_000), 5e18, 10e18, 1e18],
            [uint256(997_000_000_000_000_000), 10e18, 5e18, 1e18],
            [uint256(997_000_000_000_000_000), 5e18, 5e18, 1e18],
            [uint256(1e18), 5e18, 5e18, 1_003_009_027_081_243_732]
        ];
        for (uint256 i = 0; i < testCases.length; ++i) {
            setUp();
            uint256[4] memory testCase = testCases[i];
            uint256 outputAmount = testCase[0];
            uint256 tokenAmount0 = testCase[1];
            uint256 tokenAmount1 = testCase[2];
            uint256 inputAmount = testCase[3];

            _addLiquidity(tokenAmount0, tokenAmount1);
            token0.transfer(address(pair), inputAmount);

            vm.expectRevert(
                abi.encodeWithSelector(Pair.InvalidReserveInvariant.selector)
            );
            pair.swap(outputAmount + 1, 0, address(this));

            pair.swap(outputAmount, 0, address(this));
        }
    }

    function test_SwapToken0() public {
        uint256 tokenAmount0 = 5e18;
        uint256 tokenAmount1 = 10e18;
        _addLiquidity(tokenAmount0, tokenAmount1);

        uint256 swapAmount = 1e18;
        uint256 expectedOutputAmount = 1_662_497_915_624_478_906;
        token0.transfer(address(pair), swapAmount);

        // Expect transfer event from token1
        vm.expectEmit(true, true, true, true, address(token1));
        emit ERC20.Transfer(address(pair), address(this), expectedOutputAmount);

        // Expect Sync event from updating balances
        vm.expectEmit(true, false, false, true, address(pair));
        emit Pair.Sync(
            uint112(tokenAmount0 + swapAmount),
            uint112(tokenAmount1 - expectedOutputAmount)
        );

        // Expect Swap event from swapping tokens
        vm.expectEmit(true, true, false, true, address(pair));
        emit Pair.Swap(
            address(this),
            swapAmount,
            0,
            0,
            expectedOutputAmount,
            address(this)
        );

        pair.swap(0, expectedOutputAmount, address(this));

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        assertEq(reserve0, tokenAmount0 + swapAmount);
        assertEq(reserve1, tokenAmount1 - expectedOutputAmount);
        assertEq(token0.balanceOf(address(pair)), tokenAmount0 + swapAmount);
        assertEq(
            token1.balanceOf(address(pair)),
            tokenAmount1 - expectedOutputAmount
        );
        uint256 totalSupply0 = token0.totalSupply();
        uint256 totalSupply1 = token1.totalSupply();
        assertEq(
            token0.balanceOf(address(this)),
            totalSupply0 - tokenAmount0 - swapAmount
        );
        assertEq(
            token1.balanceOf(address(this)),
            totalSupply1 - tokenAmount1 + expectedOutputAmount
        );
    }

    function test_SwapToken1() public {
        uint256 tokenAmount0 = 5e18;
        uint256 tokenAmount1 = 10e18;
        _addLiquidity(tokenAmount0, tokenAmount1);

        uint256 swapAmount = 1e18;
        uint256 expectedOutputAmount = 453_305_446_940_074_565;
        token1.transfer(address(pair), swapAmount);

        // Expect transfer event from token0
        vm.expectEmit(true, true, true, true, address(token0));
        emit ERC20.Transfer(address(pair), address(this), expectedOutputAmount);

        // Expect Sync event from updating balances
        vm.expectEmit(true, false, false, true, address(pair));
        emit Pair.Sync(
            uint112(tokenAmount0 - expectedOutputAmount),
            uint112(tokenAmount1 + swapAmount)
        );

        // Expect Swap event from swapping tokens
        vm.expectEmit(true, true, false, true, address(pair));
        emit Pair.Swap(
            address(this),
            0,
            swapAmount,
            expectedOutputAmount,
            0,
            address(this)
        );

        pair.swap(expectedOutputAmount, 0, address(this));

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        assertEq(reserve0, tokenAmount0 - expectedOutputAmount);
        assertEq(reserve1, tokenAmount1 + swapAmount);
        assertEq(
            token0.balanceOf(address(pair)),
            tokenAmount0 - expectedOutputAmount
        );
        assertEq(token1.balanceOf(address(pair)), tokenAmount1 + swapAmount);
        uint256 totalSupply0 = token0.totalSupply();
        uint256 totalSupply1 = token1.totalSupply();
        assertEq(
            token0.balanceOf(address(this)),
            totalSupply0 - tokenAmount0 + expectedOutputAmount
        );
        assertEq(
            token1.balanceOf(address(this)),
            totalSupply1 - tokenAmount1 - swapAmount
        );
    }

    function test_MaxFlashLoan() external {
        _addLiquidity(INITIAL_TOKENS, INITIAL_TOKENS);

        // Test unsupported token (does not revert, but returns 0)
        assertEq(pair.maxFlashLoan(address(0)), 0);

        // Test success
        uint256 amount = pair.maxFlashLoan(address(token0));
        assertEq(amount, INITIAL_TOKENS);
    }

    function test_FlashFee() external {
        _addLiquidity(INITIAL_TOKENS, INITIAL_TOKENS);

        // Test revert
        vm.expectRevert(
            abi.encodeWithSelector(Pair.UnsupportedToken.selector, address(0))
        );
        pair.flashFee(address(0), LOAN_AMOUNT);

        // Test success
        uint256 fee = pair.flashFee(address(token0), LOAN_AMOUNT);
        assertEq(fee, LOAN_FEE);
    }

    function test_FlashLoan() external {
        _addLiquidity(LOAN_AMOUNT, LOAN_AMOUNT);
        FlashBorrower goodBorrower = new FlashBorrower();
        FlashBorrowerBadReturnValue badReturnValue = new FlashBorrowerBadReturnValue();
        FlashBorrowerBadRepayment noRepayment = new FlashBorrowerBadRepayment();

        // Test unsupported token
        vm.expectRevert(
            abi.encodeWithSelector(
                Pair.InsufficientFlashLoanLiquidity.selector,
                LOAN_AMOUNT
            )
        );
        pair.flashLoan(goodBorrower, address(0), LOAN_AMOUNT, "");

        // Test insufficient flash loan liquidity
        uint256 tooMuch = LOAN_AMOUNT + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                Pair.InsufficientFlashLoanLiquidity.selector,
                tooMuch
            )
        );
        pair.flashLoan(goodBorrower, address(token0), tooMuch, "");

        // Test invalid callback response
        vm.expectRevert(
            abi.encodeWithSelector(Pair.InvalidFlashLoanReceiver.selector)
        );
        pair.flashLoan(badReturnValue, address(token0), LOAN_AMOUNT, "");

        // Test failure to repay
        vm.expectRevert(abi.encodeWithSelector(Pair.FailureToRepay.selector));
        pair.flashLoan(noRepayment, address(token0), LOAN_AMOUNT, "");

        // Test successful loan
        token0.transfer(address(goodBorrower), LOAN_FEE);
        pair.flashLoan(goodBorrower, address(token0), LOAN_AMOUNT, "walker");
        assertEq(goodBorrower.initiator(), address(this));
        assertEq(goodBorrower.token(), address(token0));
        assertEq(goodBorrower.amount(), LOAN_AMOUNT);
        assertEq(goodBorrower.fee(), LOAN_FEE);
        assertEq(goodBorrower.data(), "walker");
        assertEq(goodBorrower.balanceDuringLoan(), LOAN_AMOUNT + LOAN_FEE);
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

contract FlashBorrower is IERC3156FlashBorrower {
    address public initiator;
    address public token;
    uint256 public amount;
    uint256 public fee;
    bytes public data;
    uint256 public balanceDuringLoan;

    function onFlashLoan(
        address initiator_,
        address token_,
        uint256 amount_,
        uint256 fee_,
        bytes calldata data_
    ) external returns (bytes32) {
        initiator = initiator_;
        token = token_;
        amount = amount_;
        fee = fee_;
        data = data_;
        balanceDuringLoan = ERC20(token).balanceOf(address(this));
        ERC20(token).transfer(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}

contract FlashBorrowerBadReturnValue is IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {}
}

contract FlashBorrowerBadRepayment is IERC3156FlashBorrower {
    function onFlashLoan(
        address,
        address token,
        uint256 amount,
        uint256,
        bytes calldata
    ) external returns (bytes32) {
        ERC20(token).transfer(msg.sender, amount); // fails to provide fee
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
