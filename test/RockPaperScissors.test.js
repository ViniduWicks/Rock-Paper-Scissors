const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");
//const { assert } = require("console");
const assert = require("assert");
const { getChoice, getResult } = require("./utils");

contract("RockPaperScissors", (accounts) => {
  var choice;
  before(async () => {
    this.rockPaperScissors = await RockPaperScissors.deployed();
    choice = getChoice();
  });

  it("deploys successfully", async () => {
    const address = await this.rockPaperScissors.address;
    assert.notEqual(address, 0x0);
    assert.notEqual(address, "");
    assert.notEqual(address, null);
    assert.notEqual(address, undefined);
  });

  it("should not allow playing without funding contract", async () => {
    try {
      const result = await this.rockPaperScissors.play(choice, {
        value: web3.utils.toWei("10", "wei"),
      });
    } catch (e) {
      assert.equal(
        e.reason,
        "Please bet lower than half of contract balance",
        "Error different"
      );
    }
  });

  it("should not allow playing with value 0", async () => {
    try {
      const result = await this.rockPaperScissors.play(choice, {
        value: web3.utils.toWei("0", "wei"),
      });
    } catch (e) {
      assert.equal(
        await e.reason,
        "Please provide ETH to play",
        "Error different"
      );
    }
  });

  it("should fund the contract", async () => {
    try {
      const result = await this.rockPaperScissors.fundContract({
        value: web3.utils.toWei("10", "wei"),
      });

      assert.equal(
        await web3.eth.getBalance(this.rockPaperScissors.address),
        10,
        "Contract not funded"
      );
    } catch (e) {
      console.log("error:", e);
    }
  });

  it("plays game", async () => {
    try {
      await this.rockPaperScissors.play(choice, {
        value: web3.utils.toWei("2", "wei"),
      });
      const result = await this.rockPaperScissors.result();
      if (result == "Draw") {
        assert.equal(
          await web3.eth.getBalance(this.rockPaperScissors.address),
          10,
          "Wrong result"
        );
      } else if (result == "You won") {
        assert.equal(
          await web3.eth.getBalance(this.rockPaperScissors.address),
          6,
          "Wrong result"
        );
      } else {
        assert.equal(
          await web3.eth.getBalance(this.rockPaperScissors.address),
          12,
          "Wrong result"
        );
      }
    } catch (e) {
      console.log("error:", e.reason);
    }
  });

  it("withdraws all ETH from contract", async () => {
    try {
      const result = await this.rockPaperScissors.withdrawAllETHFromContract();

      assert.equal(
        await web3.eth.getBalance(this.rockPaperScissors.address),
        0,
        "All ETH not withdrawn"
      );
    } catch (e) {
      console.log("error:", e);
    }
  });
});
