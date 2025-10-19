import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

async function setUpSmartContract() {
  const counter = await ethers.deployContract("Counter");
  const [owner] = await ethers.getSigners();
  return { counter, owner };
}

async function setUpAndInc() {
  let counter : any;
  let owner : any;
  ({ counter, owner } = await setUpSmartContract());
  await counter.inc();
  return { counter, owner };
}

describe("Counter contract", function () {
  describe.only("Test Simple", function () {
    let counter : any;
    let owner : any;

    beforeEach(async () => {
      ({ counter, owner } = await setUpSmartContract());
    });

    it("Should deploy with x = 0", async function () {
      expect(await counter.x()).to.equal(0n);
    });

    it("inc() should increment x = 1", async function () {
      console.log("X value before increment:", await counter.x());
      await counter.inc();
      console.log("X value after increment:", await counter.x());
      expect(await counter.x()).to.equal(1n);
    });

    it("Should revert on triple inc()", async function () {
      await counter.inc();
      await counter.inc();
      await expect(counter.inc()).to.be.revertedWith("Counter: x cannot be more than 2");
    });

    it("Should emit the Increment event when calling the inc() function", async function () {
      await expect(counter.inc()).to.emit(counter, "Increment").withArgs(1n);
    });
  });

  describe("Test Complexe", function () {
    it("The sum of the Increment events should match the current value", async function () {
      const counter = await ethers.deployContract("Counter");
      const deploymentBlockNumber = await ethers.provider.getBlockNumber();

      // run a series of increments
      for (let i = 1; i <= 10; i++) {
        await counter.incBy(i);
      }

      const events = await counter.queryFilter(
        counter.filters.Increment(),
        deploymentBlockNumber,
        "latest",
      );

      // check that the aggregated events match the current value
      let total = 0n;
      for (const event of events) {
        total += event.args.by;
      }

      expect(await counter.x()).to.equal(total);
    });
  });
});
