import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("JKPAdapter", function () {
  enum Options {
    NONE,
    ROCK,
    PAPER,
    SCISSORS
  }

  const DEFAULT_BID = ethers.parseEther("0.01")
  const DEFAULT_COMISSION = 10n;
  const DEFAULT_BALANCE = 0n;

  async function deployFixture() {
    const [owner, player1, player2] = await hre.ethers.getSigners();

    const JoKenPo = await hre.ethers.getContractFactory("JoKenPo");
    const joKenPo = await JoKenPo.deploy();

    const JKPAdapter = await hre.ethers.getContractFactory("JKPAdapter");
    const jkpAdapter = await JKPAdapter.deploy();

    return { joKenPo, jkpAdapter, owner, player1, player2 };
  }

  it("Should get implementation Address", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const address = await joKenPo.getAddress();
    await jkpAdapter.upgrade(joKenPo);
    const implementationAddress = await jkpAdapter.getImplementationAddress();
    expect(implementationAddress).to.equal(address);
  });

  it("Should get bid", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(joKenPo);
    const bid = await jkpAdapter.getBid();

    expect(bid).to.equal(DEFAULT_BID);
  });

  it("Should NOT get bid (not upgraded)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    await expect(jkpAdapter.getBid()).to.be.revertedWith("You must upgrade first");
  });

  it("Should get commission", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(joKenPo);
    const commission = await jkpAdapter.getCommission();

    expect(commission).to.equal(DEFAULT_COMISSION);
  });

  it("Should NOT get commission (not upgraded)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    await expect(jkpAdapter.getCommission()).to.be.revertedWith("You must upgrade first");
  });

  it("Should get balance", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);

    await jkpAdapter.upgrade(joKenPo);
    const balance = await jkpAdapter.getBalance();

    expect(balance).to.equal(DEFAULT_BALANCE);
  });

  it("Should NOT get balance (not upgraded)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    await expect(jkpAdapter.getBalance()).to.be.revertedWith("You must upgrade first");
  });

  it("Should set bid", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const newBid = ethers.parseEther("0.02");
    await jkpAdapter.upgrade(joKenPo);
    await jkpAdapter.setBid(newBid);
    const bid = await jkpAdapter.getBid();

    expect(bid).to.equal(newBid);
  });

  it("Should NOT set bid (not upgraded)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const newBid = ethers.parseEther("0.02");
    await expect(jkpAdapter.setBid(newBid)).to.be.revertedWith("You must upgrade first");
  });

  it("Should NOT set bid (permission)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const newBid = ethers.parseEther("0.02");
    await jkpAdapter.upgrade(joKenPo);
    const instance = joKenPo.connect(player1);
    await expect(instance.setBid(newBid)).to.be.revertedWith("You do not have permission");
  });

  it("Should set Commission", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const newCommission = 12n;
    await jkpAdapter.upgrade(joKenPo);
    await jkpAdapter.setCommission(newCommission);
    const Commission = await jkpAdapter.getCommission();

    expect(Commission).to.equal(newCommission);
  });

  it("Should NOT set Commission (not upgraded)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const newCommission = 12n;
    await expect(jkpAdapter.setCommission(newCommission)).to.be.revertedWith("You must upgrade first");
  });

  it("Should NOT set Commission (permission)", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    const newCommission = 12n;
    await jkpAdapter.upgrade(joKenPo);
    const instance = joKenPo.connect(player1);
    await expect(instance.setCommission(newCommission)).to.be.revertedWith("You do not have permission");
  });

  it("Should NOT upgrade (address 0 )", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    await expect(jkpAdapter.upgrade(ethers.ZeroAddress)).to.be.revertedWith("Empty address is not permited");
  });

  it("Should play alone by adapter", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    await jkpAdapter.upgrade(joKenPo);
    const instance = joKenPo.connect(player1);
    await instance.play(Options.PAPER, { value: DEFAULT_BID });
    const result = await instance.getResult();

    expect(result).to.equal("Player 1 chose their option. Waiting for player 2.")
  });

  it("Should play along by adapter", async function () {
    const { joKenPo, jkpAdapter, owner, player1, player2 } = await loadFixture(deployFixture);
    await jkpAdapter.upgrade(joKenPo);
    const instance1 = joKenPo.connect(player1);
    await instance1.play(Options.PAPER, { value: DEFAULT_BID });

    const instance2 = joKenPo.connect(player2);
    await instance2.play(Options.ROCK, { value: DEFAULT_BID });

    const result = await jkpAdapter.getResult();
    expect(result).to.equal("Paper wraps rock. Player 1 won.")
  });

});
