# What is the purpose of SafeERC20 from OpenZeppelin?

[SafeERC20 Github](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol)

## Summary

SafeERC20 is a wrapper that provides extra functionality on top of existing ERC20 functions.  The purpose of the new functionality is to increase a few aspects of safety, including automatically reverting upon failure, and adding multiple transactions when needed for best-practice.

## Weaknesses with ERC20

ERC20 is purposely a very simple standard.  The simplicity made it easy to implement and quickly gain adoption.  As such, using it safely requires knowledge of best practices, because using the raw interface directly can open contracts up to exploitation.

According to the standard, the `transfer` family of functions returns a `bool` status value, as opposed to reverting.  This gives the caller the flexibility to respond in any way, but neglecting to interpret the response correctly (or at all) can lead to vulnerabilities.  Some ERC20 contracts return their status in non-standard ways.

> TODO: What is an example of a non-standard ERC20 return value?

The `allowance` function can be front-run, such that the attacker (someone who has been granted an allowance already), can submit a transaction in front of an allowance adjustment (like up to the full allowance amount), and then after the new allowance is set submit another transaction further draining up to the new allowance.  Therefore the best practice is to always set the allowance back to zero before changing it from a non-zero value to a different non-zero value.

## How SafeERC20 works

SafeERC20 is a library that can be added onto an ERC20 like so:

```
using SafeERC20 for ERC20;
```

It adds functions that you use in place of `transfer`, `transferFrom` and `approve`.  The new functions primarily handle `bool` return values.

The `safeIncreaseAllowance` and `safeDecreaseAllowance` functions set the allowance to zero before setting to a new value.

There are some "relaxed" calls that mimics the response of ECR721 transferring to EOAs.

This library uses OpenZeppelin's other `Address.sol` utility library which provides the low-level `functionCall`, which checks that the contract has code and asserts success on the low-level return data.