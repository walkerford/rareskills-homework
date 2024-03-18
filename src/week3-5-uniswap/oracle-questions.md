# Week 3-5 Uniswap Homework Questions

## Why does the price0CumulativeLast and price1CumulativeLast never decrement?

These values accumulate new prices without ever decrementing (until the overflow happens). This mechanism helps to make the oracle's price feed harder (more expensive) to manipulate. With this cumulative price feed, the user can set up a price average over any arbitrary time period. An attacker would have to pay for an attack that outlasts the duration of the averaging period for each specific instance. The accumulator overflow is not a problem, because the difference operation over unsigned values will always produce the correct result (as long as the accumulator hasn't overflowed twice).

## How do you write a contract that uses the oracle?

The user needs to decide the time period to obtain the price average over. The contract then needs to capture the price at a given moment, then capture the price again after the time period has elapsed. With these two prices, the contract subtracts the starting price from the ending price (end - start), then divides by the time period (seconds) to get the average price for that period.

## Why are price0CumulativeLast and price1CumulativeLast stored separately? Why not just calculate `price1CumulativeLast = 1/price0CumulativeLast?

The division is expensive, so it is better to do it once per update, then many users of the price value don't have to perform the calculation redundantly.
