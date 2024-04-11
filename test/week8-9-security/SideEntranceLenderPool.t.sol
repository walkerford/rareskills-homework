// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "week8-9-security/SideEntranceLenderPool.sol";

contract SideEntranceLenderPoolTest is Test {
    SideEntranceLenderPool pool;
    Exploiter exploiter;

    uint256 constant ETHER_IN_POOL = 1 ether;

    receive() external payable {}

    function setUp() public {
        pool = new SideEntranceLenderPool();
        pool.deposit{value: ETHER_IN_POOL}();

        exploiter = new Exploiter(pool);
    }

    function test_setup() public view {
        assert(address(pool).balance == ETHER_IN_POOL);
    }

    function test_attack() public {
        // Put your solution here
        exploiter.attack();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(pool).balance, 0);
        assertGt(address(this).balance, ETHER_IN_POOL);
    }
}
