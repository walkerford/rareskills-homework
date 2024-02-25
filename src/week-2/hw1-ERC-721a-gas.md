# How does ERC-721a save gas?

[ERC-721a](https://www.azuki.com/erc721a) is an ERC-721 compatible implementation by Azuki that heavily optimizes gas usage.

The optimizations focus on reducing gas costs for minting, as they have observed that minting is the phase users most care about. Gas savings come primarily from adding batch operations. Standard ERC-721 implementations operate on a one-NFT-at-a-time basis, where ERC-721a allows multiple NFTs to be transacted at once, and therefore costing even less than a single standard ERC-721 transaction.

The optimizations fall into these three groups:

1. Duplicated storage, typical of IERC721Enumerable implementations, is removed. Those implementations are optimized for efficient reads, where ERC-721a optimizes initial writes.

2. Owner's balance is updated once per batch, instead of once per NFT.

3. Owner's data is updated once per batch, instead of once per NFT. The trick is that it only writes the owner data once at the head of a batch. Batches must be contiguous. And then when doing reads, it has to iterate through empty NFTs, up to a max-batch-size limit, looking for a valid head.
