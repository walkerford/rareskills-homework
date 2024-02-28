// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "forge-std/console.sol";
import "./EnumerableNFT.sol";

contract CheckPrime {
    EnumerableNFT nft;

    constructor(EnumerableNFT nft_) {
        nft = nft_;
    }

    function check(address owner) external view returns(uint256) {
        uint256 balance = nft.balanceOf(owner);
        console.log("check() owner", owner, "balance", balance);
        uint256 count;
        if (balance != 0) {
            for (uint256 i = balance-1; ;) {
                uint256 tokenId = nft.tokenOfOwnerByIndex(owner, i);

                if (isPrime(tokenId)) {
                    unchecked {
                        count++;
                    }
                }

                if (i == 0) {
                    break;
                }

                unchecked{
                    i--;
                }

            }
        }
        return count;
    }

    /// @notice Finds primes less than 100
    /// Checks the basic cases with equality or less-than: 0,1,2,3,5,7
    /// All others are checks by modulo division of the primes up to sqrt(100)=10
    /// The ordering has been chosen to minimize gas constant
    /// To determine primes larger than 100, modulo of prime factors needs to be incorporated up to sqrt(max_value)
    function isPrime(uint256 tokenId) public pure returns(bool) {
        if (tokenId < 2) { // 0, 1
            return false;
        }

        if (tokenId == 2) { // 2
            return true;
        }

        if (tokenId % 2 == 0) { // 4, 6, 8, 10, 12, 14...
            return false;
        }

        if (tokenId < 9) { // 3, 5, 7
            return true;
        }

        if (tokenId % 3 == 0 || tokenId % 5 == 0 || tokenId % 7 == 0) { // 9, 15, 21...
            return false;
        }
        return true; // 11, 17, 19...
    }
}