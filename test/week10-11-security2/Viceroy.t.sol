// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Viceroy.sol";

contract ViceroyTest is Test {
    OligarchyNFT nft;
    Governance governance;
    address attacker;

    function setUp() external {
        attacker = makeAddr("attacker");
        nft = new OligarchyNFT(attacker);
        governance = new Governance{value: 10 ether}(nft);
    }

    function test_setUp() external {
        assertEq(address(governance.communityWallet()).balance, 10 ether);
    }

    function test_revertsWhen_transfer() external {
        vm.expectRevert(
            abi.encodeWithSelector(OligarchyNFT.CannotTransfer.selector)
        );
        nft.transferFrom(attacker, address(this), 0);
    }
}
