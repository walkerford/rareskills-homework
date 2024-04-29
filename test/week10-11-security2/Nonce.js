const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NonceTest", function () {
  it("adds", async function () {
    const [signer] = await ethers.getSigners();

    // Nonce is 1
    let nonce = await ethers.provider.getTransactionCount(signer.address);
    expect(nonce, 1);

    // Deploy counter
    const counter = await (await ethers.getContractFactory("Counter")).deploy();

    // Nonce is 2
    nonce = await ethers.provider.getTransactionCount(signer.address);
    expect(nonce, 2);

    // Call add
    await counter.add();

    // Nonce is 3
    nonce = await ethers.provider.getTransactionCount(signer.address);
    expect(nonce, 3);
  });
});
