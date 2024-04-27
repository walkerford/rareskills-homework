// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week10-11-security2/Viceroy.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ViceroyTest is Test {
    OligarchyNFT nft;
    Governance governance;
    GovernanceAttacker attacker;
    address attackerWallet;

    function setUp() external {
        attackerWallet = makeAddr("attacker");

        vm.prank(attackerWallet);
        attacker = new GovernanceAttacker();

        vm.expectEmit(true, true, true, false);
        emit IERC721.Transfer(address(0), attackerWallet, 1);

        nft = new OligarchyNFT(attackerWallet);
        governance = new Governance{value: 10 ether}(nft);
    }

    function test_setUp() external {
        assertEq(address(governance.communityWallet()).balance, 10 ether);
        assertEq(attackerWallet.balance, 0);
    }

    function test_revertsWhen_transfer() external {
        vm.expectRevert("Cannot transfer nft");
        nft.transferFrom(attackerWallet, address(this), 0);
    }

    function test_revertsWhen_appointViceroy() external {
        vm.expectRevert("not an oligarch");
        governance.appointViceroy(address(this), 1);
    }

    function test_attack() external {
        nft.safeTransferFrom(address(0), address(this), 1);
        attacker.attack(governance);
        // _checkSolved();
    }

    function test_NFT() external {
        vm.expectEmit(true, true, true, false);
        emit IERC721.Transfer(address(0), address(this), 1);
        new OligarchyNFT(address(this));
    }

    function _checkSolved() internal {
        assertEq(address(governance.communityWallet()).balance, 0);
        assertEq(attackerWallet.balance, 10 ether);
        assertEq(vm.getNonce(attackerWallet), 2);
    }
}

contract GovernanceAttacker {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function attack(Governance) external view {
        console.log("attack()");

        // governance.appointViceroy(address(this), 1);
    }
}
