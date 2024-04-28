// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/RewardToken.sol";

contract RewardTokenTest is Test {
    RewardToken token;
    NftToStake nft;
    Depositoor depositor;
    RewardTokenAttacker attacker;

    function setUp() external {
        attacker = new RewardTokenAttacker();

        nft = new NftToStake(address(attacker));
        depositor = new Depositoor(nft);
        token = new RewardToken(address(depositor));

        depositor.setRewardToken(token);
    }

    function test_setUp() external {
        assertGt(uint160(address(depositor.rewardToken())), 0);
        assertEq(address(depositor.rewardToken()), address(token));
        assertEq(token.balanceOf(address(depositor)), 100e18);
    }

    function test_attack() external {
        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(address(attacker).balance, 100 ether);
    }
}

contract RewardTokenAttacker {}
