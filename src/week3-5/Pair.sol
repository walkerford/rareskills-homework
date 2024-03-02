// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "solady/tokens/ERC20.sol";
import "solady/utils/ReentrancyGuard.sol";
import "solady/utils/FixedPointMathLib.sol";
import "./Factory.sol";
import "./UQ112x112.sol";

// contract Pair is ERC20, IUniswapV2Pair {
contract Pair is ERC20 {
    using UQ112x112 for uint224;

    error BalanceOutOfBounds();
    error InsufficientLiquidity();

    event Mint(address to, uint256 amount0, uint256 amount1);
    event Sync(uint112 reserve0, uint112 reserve1);

    uint256 public constant MINIMUM_INITIAL_SHARES = 10_000;

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

    function mint(address to) external returns (uint256 shares) {
        (uint112 reserve0_, uint112 reserve1_, ) = getReserves();

        // Get balances, which includes anything sent as a part of the
        // transaction
        uint256 balance0 = ERC20(token0).balanceOf(address(this));
        uint256 balance1 = ERC20(token1).balanceOf(address(this));

        // Calculate how much was added as part of the transaction
        uint256 amount0 = balance0 - reserve0_;
        uint256 amount1 = balance1 - reserve1_;

        // TODO: Add fee

        uint256 totalSupply_ = totalSupply();

        // Compute shares that should be minted
        if (totalSupply_ == 0) {
            // Initial case burns an amount of shares

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
            uint256 l0 = (amount0 * totalSupply_) / reserve0_;
            uint256 l1 = (amount1 * totalSupply_) / reserve1_;

            // Return the minimum
            shares = FixedPointMathLib.min(l0, l1);
        }

        // Validiate enough liquidity was provided
        if (shares == 0) {
            revert InsufficientLiquidity();
        }

        // Mint shares
        _mint(to, shares);

        // Update state
        _update(balance0, balance1, reserve0_, reserve1_);

        // TODO: Fee accounting

        // Q: Why not also emit the shares?
        emit Mint(msg.sender, amount0, amount1);
    }

    /*** PRIVATE FUNCTIONS ***/

    function _mint() private {}

    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 reserve0,
        uint112 reserve1
    ) private {
        // Bounds check balances
        if (balance0 <= type(uint112).max || balance1 <= type(uint112).max) {
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
        if (timeElapsed != 0 || reserve0 != 0 || reserve1 != 0) {
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
