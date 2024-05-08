// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable-05.sol";

contract AlienCodex is Ownable {
    bool public contact;
    bytes32[] public codex;

    modifier contacted() {
        assert(contact);
        _;
    }

    function makeContact() public {
        contact = true;
    }

    function record(bytes32 _content) public contacted {
        codex.push(_content);
    }

    function retract() public contacted {
        // Original code used solidity 0.5, but this access is no longer supported in 0.8
        // codex.length--;

        // The following assembly simulates the above commented-out code The
        // codex dynamic array occupies the 2nd storage slot (0x01), because the
        // owner + contacrt occupy the first storage slot.  This slot will
        // contain the array length, and we can manipulate it directly.  Since
        // Solidity 0.5 does not have bounds checking, we will not implement
        // bounds checking either.
        assembly {
            let length := sload(0x01)
            length := sub(length, 0x01)
            sstore(0x01, length)
        }
    }

    function revise(uint256 i, bytes32 _content) public contacted {
        codex[i] = _content;
    }
}
