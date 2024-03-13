// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/console.sol";

import "openzeppelin-contracts/contracts/interfaces/IERC3156.sol";
import "solady/tokens/ERC20.sol";
import "solady/utils/ReentrancyGuard.sol";
import "solady/utils/FixedPointMathLib.sol";
import "./Factory.sol";
import "./UQ112x112.sol";

uint256 constant MINIMUM_INITIAL_SHARES = 1e3;
bytes32 constant SELECTOR_ON_FLASH_LOAN = keccak256(
    "ERC3156FlashBorrower.onFlashLoan"
);

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract Pair is ERC20, ReentrancyGuard, IERC3156FlashLender {
    using UQ112x112 for uint224;

    error BalanceOutOfBounds();
    error FailureToRepay();
    error InsufficientFlashLoanLiquidity(uint256 amount);
    error InsufficientLiquidity();
    error InsufficientLiquidityBurned();
    error InsufficientInput();
    error InsufficientOutput();
    error InvalidFlashLoanReceiver();
    error InvalidReserveInvariant();
    error InvalidTo(address to);
    error MintingSlippageNotMet();
    error TransferFailed();
    error UnsupportedToken(address token);

    event Burn(
        address indexed from,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Mint(address indexed to, uint256 amount0, uint256 amount1);
    event Swap(
        address indexed from,
        uint256 amountIn0,
        uint256 amountIn1,
        uint256 amountOut0,
        uint256 amountOut1,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    bytes4 private constant TRANSFER_SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    string private constant _name = "Pair Shares";
    string private constant _symbol = "PS";

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;

    address public immutable factory;
    address public immutable token0;
    address public immutable token1;

    uint32 private _blockTimestampLast;
    uint112 private _reserve0;
    uint112 private _reserve1;

    constructor(address token0_, address token1_) {
        token0 = token0_;
        token1 = token1_;
        factory = msg.sender;
    }

    /*** PUBLIC FUNCTIONS ***/

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function getReserves()
        public
        view
        returns (uint112 reserve0, uint112 reserve1, uint256 blockTimestampLast)
    {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = _blockTimestampLast;
    }

    function burn(
        address to
    ) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        (uint112 reserve0, uint112 reserve1, ) = getReserves();
        address token0_ = token0;
        address token1_ = token1;
        uint256 balance0 = ERC20(token0_).balanceOf(address(this));
        uint256 balance1 = ERC20(token1_).balanceOf(address(this));
        uint256 shares = balanceOf(address(this));

        // TODO: fee

        uint256 totalShares = totalSupply();
        amount0 = (shares * balance0) / totalShares;
        amount1 = (shares * balance1) / totalShares;
        if (amount0 == 0 && amount1 == 0) {
            revert InsufficientLiquidityBurned();
        }

        _burn(address(this), shares);
        _safeTransfer(token0_, to, amount0);
        _safeTransfer(token1_, to, amount1);
        balance0 = ERC20(token0_).balanceOf(address(this));
        balance1 = ERC20(token1_).balanceOf(address(this));

        _update(balance0, balance1, reserve0, reserve1);
        // TODO: Update klast if using fee
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function mint(
        address to,
        uint256 minimumShares
    ) external nonReentrant returns (uint256 shares) {
        (uint112 reserve0, uint112 reserve1, ) = getReserves();

        // Get balances, which includes anything sent as a part of the
        // transaction
        uint256 balance0 = ERC20(token0).balanceOf(address(this));
        uint256 balance1 = ERC20(token1).balanceOf(address(this));

        // Calculate how much was added as part of the transaction
        uint256 amount0;
        uint256 amount1;
        unchecked {
            // balance will never be less than than reserve
            amount0 = balance0 - reserve0;
            amount1 = balance1 - reserve1;
        }

        // TODO: Add fee

        uint256 totalShares = totalSupply();

        // Compute shares that should be minted initially
        if (totalShares == 0) {
            // Initial case burns a small fixed amount of shares

            // Calulate shares. Subtraction bounds check will catch if not
            // enough liquity was provided
            shares =
                FixedPointMathLib.sqrt(amount0 * amount1) -
                MINIMUM_INITIAL_SHARES;

            // Mint and burn minimum initial shares
            _mint(address(0), MINIMUM_INITIAL_SHARES);
        } else {
            // Regular case returns shares relative to the minimum liquidity
            // portion provided, which incentivizes users to submit equal
            // proportions, maintaining the pool's k ratio.

            // Calulcate shares for each amount
            uint256 l0 = (amount0 * totalShares) / reserve0;
            uint256 l1 = (amount1 * totalShares) / reserve1;

            // Return the minimum
            shares = FixedPointMathLib.min(l0, l1);
        }

        // Validiate enough liquidity was provided
        if (shares == 0) {
            revert InsufficientLiquidity();
        }

        // Protect against slippage with minimumShares
        if (shares < minimumShares) {
            revert MintingSlippageNotMet();
        }

        // Mint shares
        _mint(to, shares);

        // Update state
        _update(balance0, balance1, reserve0, reserve1);

        // TODO: Fee accounting

        // Q: Why not also emit the shares?
        emit Mint(msg.sender, amount0, amount1);
    }

    function swap(
        uint256 amountOut0,
        uint256 amountOut1,
        address to
    ) external nonReentrant {
        // console.log("swap()", amountOut0, amountOut1, string(data));

        // Validate non-zero outs
        if (amountOut0 == 0 && amountOut1 == 0) {
            revert InsufficientOutput();
        }

        // Validate sufficient reserves
        (uint112 reserve0, uint112 reserve1, ) = getReserves();
        // Reserves should never go to zero or that will break k value
        if (amountOut0 >= reserve0 || amountOut1 >= reserve1) {
            revert InsufficientLiquidity();
        }

        uint256 balance0;
        uint256 balance1;

        // Transfer tokens, handle data, and get balances
        {
            // internal scope allows temporary variable space to be reused,
            // to avoid stack-to-deep errors.

            // TODO: Test if optimizer makes these local variables unnecessary.
            address token0_ = token0;
            address token1_ = token1;

            // Validate `to`
            if (to == token0_ || to == token1_) {
                revert InvalidTo(to);
            }

            // Transfer tokens
            if (amountOut0 > 0) {
                _safeTransfer(token0_, to, amountOut0);
            }
            if (amountOut1 > 0) {
                _safeTransfer(token1_, to, amountOut1);
            }

            // Save balances
            balance0 = ERC20(token0_).balanceOf(address(this));
            balance1 = ERC20(token1_).balanceOf(address(this));
        }

        // Calculate "in" amounts
        uint256 amountIn0 = balance0 > reserve0 - amountOut0
            ? balance0 - (reserve0 - amountOut0)
            : 0;
        uint256 amountIn1 = balance1 > reserve1 - amountOut1
            ? balance1 - (reserve1 - amountOut1)
            : 0;

        // console.log("balance, reserve, amountOut 0:", balance0, uint256(reserve0), amountOut0);
        // console.log("balance, reserve, amountOut 1:", balance1, uint256(reserve1), amountOut1);

        // Validate "in" amounts
        if (amountIn0 == 0 && amountIn1 == 0) {
            revert InsufficientInput();
        }

        // Handle fee and validate reserve invariant
        {
            // internal scope allows temporary variable space to be reused,
            // to avoid stack-to-deep errors.

            // Account for fee with integer math
            // 0.3% = 3 / 1000
            uint256 balanceLessFee0 = (balance0 * 1000) - (amountIn0 * 3);
            uint256 balanceLessFee1 = (balance1 * 1000) - (amountIn1 * 3);

            // console.log("aIn0", amountIn0);
            // console.log("aIn1", amountIn1);

            // console.log("ab0", balanceLessFee0);
            // console.log("ab1", balanceLessFee1);

            // uint256 ab01 = balanceLessFee0 * balanceLessFee1;
            // console.log("ab0*ab1=", ab01);
            // console.log("r0*r1=", uint256(reserve0) * uint256(reserve1) * (1000**2));

            // Validate reserve invariant
            // reserves need to be multiplied by 1000**2 to account for integer math above
            if (
                balanceLessFee0 * balanceLessFee1 <
                uint256(reserve0) * uint256(reserve1) * (1000 ** 2)
            ) {
                revert InvalidReserveInvariant();
            }
        }

        // Update state
        _update(balance0, balance1, reserve0, reserve1);

        emit Swap(msg.sender, amountIn0, amountIn1, amountOut0, amountOut1, to);
    }

    /**
     * @param token that will be loaned
     * @dev does not revert, returns 0 in case of unsupported token
     */
    function maxFlashLoan(address token) public view returns (uint256 amount) {
        // Validate token
        if (token != token0 && token != token1) {
            amount = 0;
        } else {
            // Calculate amount
            // Q: Can we lend out the entire token balance, or do we need to keep at least 1?
            amount = ERC20(token).balanceOf(address(this));
        }
    }

    /**
     *
     * @param token that will be loaned
     * @param amount that will be loaned
     * @dev reverts when passed an unsupported token
     */
    function flashFee(
        address token,
        uint256 amount
    ) public view returns (uint256 fee) {
        // Validate token
        if (token != token0 && token != token1) {
            revert UnsupportedToken(token);
        }

        // Calculate fee
        fee = (amount * 3) / 1000;
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        // Validate amount (also validates token)
        if (amount > maxFlashLoan(token)) {
            revert InsufficientFlashLoanLiquidity(amount);
        }

        uint256 fee = flashFee(token, amount);
        uint256 balanceBefore = ERC20(token).balanceOf(address(this));

        // Transfer loan
        ERC20(token).transfer(address(receiver), amount);

        // Callback
        bytes32 result = receiver.onFlashLoan(
            msg.sender,
            token,
            amount,
            fee,
            data
        );
        if (result != SELECTOR_ON_FLASH_LOAN) {
            revert InvalidFlashLoanReceiver();
        }

        // Check repayment
        uint256 balanceAfter = ERC20(token).balanceOf(address(this));
        if (balanceAfter < balanceBefore + fee) {
            revert FailureToRepay();
        }

        return true;
    }

    /*** PRIVATE FUNCTIONS ***/

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(TRANSFER_SELECTOR, to, value)
        );
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) {
            revert TransferFailed();
        }
        // require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }

    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 reserve0,
        uint112 reserve1
    ) private {
        // Bounds check balances
        if (balance0 >= type(uint112).max || balance1 >= type(uint112).max) {
            revert BalanceOutOfBounds();
        }

        // Get timestamp
        uint32 blockTimestamp = uint32(block.timestamp % (2 ** 32));

        // Overflow is expected, around year 2107. Math will be ok.
        uint32 timeElapsed;
        unchecked {
            timeElapsed = blockTimestamp - _blockTimestampLast;
        }

        // Update variables for oracle
        // Skip any zero cases
        if (timeElapsed != 0 && reserve0 != 0 && reserve1 != 0) {
            price0CumulativeLast =
                uint256(UQ112x112.encode(reserve0).uqdiv(reserve1)) *
                timeElapsed;
            price1CumulativeLast =
                uint256(UQ112x112.encode(reserve1).uqdiv(reserve0)) *
                timeElapsed;
        }

        // Update state
        _reserve0 = uint112(balance0);
        _reserve1 = uint112(balance1);
        _blockTimestampLast = blockTimestamp;

        emit Sync(_reserve0, _reserve1);
    }
}
