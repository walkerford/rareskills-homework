// SPDX-License-Identifier: Unlicencsed
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    constructor() ERC20("Reward Token", "RT") Ownable(_msgSender()) {}

    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ERC20InvalidReceiver(to);
        _mint(to, amount);
    }
}