// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Knight {
    constructor(GatekeeperOne gatekeeper) {
        // To pass gate1, the player needs to call a contract so tx.origin !=
        // msg.sender

        // To pass gate2, a correct amount of gas needs to be passed

        // Value for evm=paris
        // uint64 gasKey = 50000 + 7605;

        // Value for evm=shanghai
        uint64 gasKey = 50000 + 7602;

        // To pass gate3, part 1, the bytes 2 and 3 (0-indexed) need to be zero.
        // Part 2 comes for free as long as no other bits are changes. Part 3
        // requires the base of the gatekey to be tx.origin.
        uint64 mask = 0xFFFF_FFFF_0000_FFFF;
        bytes8 gatekey = bytes8(uint64(uint160(tx.origin)) & mask);

        // Enter with the correct key
        gatekeeper.enter{gas: gasKey}(gatekey);

        // To find the gasKey, I just looped through up to 8191 values until I
        // found one that worked.

        // for (uint256 i; i < 8191; i++) {
        //     try gatekeeper.enter{gas: 50000 + i}(gatekey) returns (bool) {
        //         console.log("OUT", i);
        //         break;
        //     } catch {}
        // }
    }
}
