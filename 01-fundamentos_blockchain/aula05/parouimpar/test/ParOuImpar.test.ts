import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

type GameData = {
  choiceP1: number; 
  numberP1: number; 
  numberP2: number; 
  lastWinner: number; 
};

function fetchGameData(rawGameData: any) {
  const gameData: GameData = {
    choiceP1: Number(rawGameData[0]),
    numberP1: Number(rawGameData[1]),
    numberP2: Number(rawGameData[2]),
    lastWinner: Number(rawGameData[3])
   };
  return gameData;
}

describe("ParOuImpar", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {

    const [player1, player2] = await hre.ethers.getSigners();

    const ParOuImpar = await hre.ethers.getContractFactory("ParOuImpar");
    const parOuImpar = await ParOuImpar.deploy();

    return { parOuImpar, player1, player2 };
  }

  it("Should Have No Player", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    const gameData = fetchGameData(await parOuImpar.gameData());
    expect(gameData.choiceP1).to.equal(0);
  });

  
  it("Should not Init (Wrong Choice)", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await expect(parOuImpar.initGame(3, 1)).to.be.revertedWith("Choose 1 or 2");
  });

  it("Should not Init (Wrong Number)", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await expect(parOuImpar.initGame(1, 0)).to.be.revertedWith("Number choice must be between 1 and 10");
  });

  it("Should Init Game", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await parOuImpar.initGame(2, 5);
    const gameData = fetchGameData(await parOuImpar.gameData());
    expect(gameData.choiceP1).to.not.equal(0);
  });


  it("Should not Play Game (Choice == 0)", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await parOuImpar.initGame(2, 5);
    const gameData = fetchGameData(await parOuImpar.gameData());
    expect(gameData.choiceP1).to.not.equal(0);
  });

  it("Should not Play Game (Wrong Number)", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await parOuImpar.initGame(2, 5);
    await expect(parOuImpar.playGame(11)).to.be.revertedWith("Choose a number between 1 and 10");
  });

  it("Should Play Game (Winner P2)", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await parOuImpar.initGame(2, 5);
    await parOuImpar.playGame(5);
    const lastGameData = fetchGameData(await parOuImpar.lastGameData());
    expect(lastGameData.lastWinner).to.equal(2);
  });

  it("Should Play Game (Winner P1)", async function () {
    const { parOuImpar } = await loadFixture(deployFixture);
    await parOuImpar.initGame(1, 5);
    await parOuImpar.playGame(5);
    const lastGameData = fetchGameData(await parOuImpar.lastGameData());
    expect(lastGameData.lastWinner).to.equal(1);
  });

});
