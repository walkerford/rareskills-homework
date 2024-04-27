// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Viceroy.sol";
import "week10-11-security2/ViceroyAttacker.sol";
import "@openzeppelin-v4/contracts/token/ERC721/ERC721.sol";

contract ViceroyTest is Test {
    OligarchyNFT nft;
    Governance governance;
    GovernanceAttacker attacker;
    address attackerWallet;

    function setUp() external {
        attackerWallet = makeAddr("attacker");

        // Deploy attacker
        vm.prank(attackerWallet);
        attacker = new GovernanceAttacker();

        vm.expectEmit(true, true, true, false);
        emit IERC721.Transfer(address(0), address(attacker), 1);

        // Assign OligarchyNFT to attacker
        nft = new OligarchyNFT(address(attacker));

        // Deploy Governance
        governance = new Governance{value: 10 ether}(nft);
    }

    function test_setUp() external {
        // Validate initial Governance balance
        assertEq(address(governance.communityWallet()).balance, 10 ether);

        // Validate initial attacker balance
        assertEq(address(attacker).balance, 0);

        // Validate NFT ownership
        assertEq(nft.balanceOf(address(attacker)), 1);
        assertEq(nft.ownerOf(1), address(attacker));
    }

    function test_revertsWhen_transferUnauthorized() external {
        vm.expectRevert("Cannot transfer nft");
        vm.prank(address(attacker));
        nft.transferFrom(address(attacker), address(this), 1);
    }

    function test_revertsWhen_appointViceroyUnauthorized() external {
        vm.expectRevert("not an oligarch");
        governance.appointViceroy(address(this), 1);
    }

    function test_createNftShouldEmit() external {
        vm.expectEmit(true, true, true, false);
        emit IERC721.Transfer(address(0), address(this), 1);
        new OligarchyNFT(address(this));
    }

    function test_attack() external {
        // Start attack
        vm.prank(attackerWallet);
        attacker.attack(governance);

        _checkSolved();
    }

    function _checkSolved() internal {
        // Community wallet should be drained
        assertEq(address(governance.communityWallet()).balance, 0);

        // Attacker should have all the ether
        assertEq(attackerWallet.balance, 10 ether);

        // Should have only taken one transaction
        assertEq(vm.getNonce(attackerWallet), 1);
    }
}
