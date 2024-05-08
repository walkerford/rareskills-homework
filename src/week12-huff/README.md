# Huff Puzzles Notes

## CallValue

I used `mload` instead of `mstore`. I figured how how to get the debugger to
land inside the huff function. Code is not displayed, but you can step through.
Press "c" to jump to the next call. The way the huff deployer uses forge is with
the vm.ffi cheat-code, which injects the huff code. So the instructions will all
swap to the correct ones after the PC steps to line 1.

## CalldataLength

Straightforward use of `calldatasize`.

## MyEtherBalance

Struggled to get the right address. First I went with the Huff contracts
address. Then I went with the tx.origin (which is the address of the default
test user in forge test). The correct answer is the msg.sender (`caller`).

I realized in the debugger I was pressing 'c' instead of 'C' to jump to the next
call, which was not taking me to the right place.

## Add1

This one requires doing function selector decoding. Huff has a helper function
`__FUNC_SIG` which makes each function resolver line pretty clean, like so:

```
    dup1 __FUNC_SIG(add1)   eq addJump  jumpi
```

The debugger gave me trouble at first, but I figured out how to set a
break-point and then use "C" to jump to the call after the breakpoint. It's
helpful to create a clean test function that just makes the call that you want,
so that you can efficiently get into the Huff code and debug.

## Multiply

Working out the overflow was a bit tricky. I used the property that dividing the
product by one multiplicand should result in the other. I had to also do a zero
check, so there wouldn't be a divide-by-zero error.

Breakpoints don't work in `forge test --debug`, so I used this instead:

```
forge debug --mc MultiplyTest --sig "testMe()"
```

## Nonpayable

Passed on first attempt.

## FooBar

Straightforward. Had some spelling errors, but I was able to read through the
messy error message to find them out.ß

## SimpleStore

I forgot to store the value in memory after loading it from storage. Can't
forget that the stack is not accessible to `return`;

## RevertCustom

I had to read up on how to load an error with `__ERROR()`. Also used return
instead of revert the first time.

I also figured out how to send the data manually. The error data is the
keccak256 of the error signature that is bit-shifted to the left (by 0xE0).

## RevertString

This was tougher. It forced me to look at abi.encoding more closely. You have to
look at the test to see how it wants the data encoded. It wasn't like
`abi.encode(string)` or even `abi.encode(bytes)` but `abi.encode((bytes))`. So
you have make sure to include that extra tuple layer in the encoding.

Because we're encoding a tuple, the first slot is the address of the first
variable's data (which is located in the second slot in this case). The second
and third slots encode the bytes datatype. The second slot is the length of of
bytes. The third slot is the data, shifted all the way left.

I had to use `console.logBytes` and `console.logBytes32` to see what the data
should look like. This helped me connect the dots with the Solidity
documentation, which takes a very mathematical approach to its definition style,
and almost assume you know how it works before you read it.

## SumArray

My understanding of the abi encoding was still a bit wrong and I can't yet
completely resolve how the solidity documentation puts it. But looking at the
data again in `console.log` I was able to recognize the data structure and then
craft my solution around that.

The encoding looks the same whether you use `abi.encode(uint256[])` or
`abi.encode((uint256))`, which I was a bit surprised about. My understanding
from the last test might have been a little off.

The first item in the encoding of a dynamic array is the length of the elements.
I could ignore this since that is fixed in this function.

The second item in the encoding of a dynamic array is the number of elements.

Third element and beyond is the data. You iterate through the elements based on
the count and the element width.

## Keccak

I couldn't figure out why the `keccak256` op-code wasn't working, but that is
because the right op-code is `sha3`.

I was not getting the right hash because I was adding an offset for a 4-byte
function signature, but in this case there is none.

I also didn't realize I needed to encode the answer as bytes32 instead of bytes.

## MaxOfArray

Similar to SumArray. Just had to work through some bugs with the debugger. I got
off on the indexes for the `swap` operations. I was returning instead of
reverting on a zero-sized array.

I'm still a bit confused by the 0x20 that is the first element in the abi
encoded array.

## Create

This was really hard. It doesn't seem like there is great documentation on how
to generate a contract within a contract using opcodes.

I first created the runtime code only, not realizing there is another layer of
abstraction that expects extra init code to be present. This makes sense, as it
gives the user the chance to customize the contract setup programmatically. When
you submit code with `create`, the code blob is sent to address 0 and executed
(called the init execution). It is expected that the init execution here will
copy the actual runtime program into memory and return that. So there are two
layers of creating the program, loading it into memory, and returning the
program.

I thought I found an optimization, which was to use larger `push` opcodes to
push more bytes in. But this missed the fact that push only creates one new item
on the stack. Often you need multiple items, so you need multiple pushes, even
if its a bunch of zeros. I did use `push0` where possible, to save one byte.

The last detail I figured out was subtle, but `return` takes from the upper
bytes of memory, not the lower bytes, so you have to left-shift your code in
memory. I was only able to figure this out because I saw the highlighting in the
debugger that didn't include the right section from memory. I might have noticed
it without the highlighting by looking at the return value.

The website evm.codes was helpful to step through the raw opcodes.

When it all worked, I was shocked that I could step through in the debugger and
watch every stage of the deployment. Set a breakpoint before the code that calls
the huff, then press `C` three times to skip through the foundry breakpoint
abstraction, then you will be to the huff code.

## Emitter

Straightforward. I had an extra "x" in one of the literals, and that produces an
unintelligible error, so I had to just cut out chunks of code until I had the
one with the error.

The emit opcode is `log`. Make sure you use the right number of topics.

## Donations

I solved it by just using `selfbalance` instead of implementing a mapping in
storage. If I have time, I will come back and implement the mapping, but since
the test didn't test for it, I'm moving forward to the next lessons.

## SendEther

Straightforward. `call` sure takes a lot of arguments. I find it odd that you
specify the return offset and size, for the data that you will be receiving
back. I guess you should know this information from the function signature, and
this gives you the ability to ignore the return value.

## BasicBank

Straightforward. This contract added a balance check. I didn't implement address
checking, because the test didn't test for it.

## Distributor

Wrote from scratch and almost passed right away. I think the layout of arrays
finally clicked. That first element is a pointer to the start of the array's
data section. So if there are two arrays, there will be two pointers to two
different data sections. The data section starts with the length of the array,
followed by each element in the array. So when passing an array as a function
parameter, even when it is the only parameter, solidity is still going to encode
it with those data section pointers, basically as if it were a tuple of one
item.

## SimulateArray

Had to implement the interface of an array. I had to figure out how to set up a
constructor in order to initialize storage location for the array pointers. I
used two: one for the array start and one for array end. I used some macros to
reduce duplicated code. Bugs I had to work out were things like forgetting the
`sload` after loading a storage slot, and getting the wrong order on the `sub`
operation.

## Ethernaut -- #19 Alien Codex

Had to underflow an array's length to give access to the entire storage of the
contract. Then use this access to over-write the owner variable.

I first had to realize that the storage address space was constrained to 2^256
addresses. Then I had to figure out that the data section of the array starts at
the keccak of the slot its variable is assigned.

I first implemented in solidity, in order to check myself, then I implemented in
huff.

The longest part was debugging the encoding of the two parameters to the
`revise()` function. Having the function signature at the start of the calldata
means that you have to break up each 256 bit value into two pieces, and upper
224 bits and a lower 32 bits, and make sure those are shifted in the right
direction. You take this work for granted when solidity does it for you.

Another thing I had to do was port the code from the Ethernaut repo. It was
written for Solidity 0.5.0, which had no checks on the array. I ported it to
0.8.0, so the rest of the project would still compile. The latest Solidity did
not allow modifying the array's length, so I wrote the equivalent action in Yul,
modifying the storage slot of the array manually.

# Questions

For Create, is there a way to generate the opcodes and sizes using huff instead
of manually?

For Donations, finish by implementing a mapping.
