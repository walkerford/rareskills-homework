// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "week3-5/Factory.sol";

contract TestToken is ERC20 {
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
