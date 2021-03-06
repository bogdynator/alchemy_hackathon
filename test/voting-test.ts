import { messagePrefix } from "@ethersproject/hash";
import { expect } from "chai";
import { Console } from "console";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { userInfo } from "os";

import { VotingSystem, VotingSystem__factory } from "../typechain";
import { Token__factory } from "../typechain";

describe("Test Voting System", async () => {
  let VotingFactory: any;
  let Voting: any;
  let TokenFactory: any;
  let Token: any;

  let user: any;
  let andy: any;
  let bob: any;
  let alice: any;

  before(async () => {
    [user, bob, andy, alice] = await ethers.getSigners();
    VotingFactory = (await ethers.getContractFactory("VotingSystem", user)) as VotingSystem__factory;
    TokenFactory = (await ethers.getContractFactory("Token", user)) as Token__factory;
  });

  beforeEach(async () => {
    Token = await TokenFactory.deploy("Alchemy Token", "ATK");
    Voting = await VotingFactory.deploy(Token.address);
    await Token.transferOwnership(Voting.address);
  });

  it("It was deployed correctly", async () => {
    expect(await Token.name()).to.be.equals("Alchemy Token");
    expect(await Token.symbol()).to.be.equals("ATK");
  });

  xit("It can add a hackathon", async () => {
    let name = "First Hackathon";
    let description = "Voting System with ERC20";
    let endDate = ethers.provider.send("evm_increaseTime", [7 * 60 * 60 * 24]); //7 days
    let votingDate = ethers.provider.send("evm_increaseTime", [17 * 60 * 60 * 24]); //10 days
    let owner = bob.address;

    expect(await Voting.addHackathon(name, description, endDate, votingDate, owner))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(name, description, endDate, votingDate, owner);

    await Voting.printHackathon(0);
  });

  xit("It can add 2 hackathons", async () => {
    let name1 = "First Hackathon";
    let description1 = "Voting System with ERC20";
    let endDate1 = ethers.provider.send("evm_increaseTime", [7 * 60 * 60 * 24]); //7 days
    let votingDate1 = ethers.provider.send("evm_increaseTime", [17 * 60 * 60 * 24]); //10 days
    let owner1 = bob.address;

    expect(await Voting.addHackathon(name1, description1, endDate1, votingDate1, owner1))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(name1, description1, endDate1, votingDate1, owner1);

    let name2 = "Second Hackathon";
    let description2 = "Voting System with ERC20";
    let endDate2 = ethers.provider.send("evm_increaseTime", [7 * 60 * 60 * 24]); //7 days
    let votingDate2 = ethers.provider.send("evm_increaseTime", [17 * 60 * 60 * 24]); //10 days
    let owner2 = bob.address;

    expect(await Voting.addHackathon(name2, description2, endDate2, votingDate2, owner2))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(name2, description2, endDate2, votingDate2, owner2);

    await Voting.printHackathon(0);
    await Voting.printHackathon(1);
  });

  xit("It can add a project", async () => {
    let name = "First Hackathon";
    let description = "Voting System with ERC20";
    let endDate = ethers.provider.send("evm_increaseTime", [7 * 60 * 60 * 24]); //7 days
    let votingDate = ethers.provider.send("evm_increaseTime", [17 * 60 * 60 * 24]); //10 days
    let owner = bob.address;

    expect(await Voting.addHackathon(name, description, endDate, votingDate, owner))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(name, description, endDate, votingDate, owner);

    await Voting.printHackathon(0);

    let nameP = "Project 1";
    let descriptionP = "App for hackathons";
    let contractAddress = "address";
    let frontEndURL = "https://frontend.com";
    let projectOwner = bob.address;

    expect(await Voting.addProject(nameP, descriptionP, contractAddress, frontEndURL, projectOwner))
      .to.emit(Voting, "ProjectAdded")
      .withArgs(nameP, descriptionP, contractAddress, frontEndURL, projectOwner);

    await Voting.printProject(0, 0);
  });

  xit("It can add 3 projects.", async () => {
    let name = "First Hackathon";
    let description = "Voting System with ERC20";
    let endDate = ethers.provider.send("evm_increaseTime", [7 * 60 * 60 * 24]); //7 days
    let votingDate = ethers.provider.send("evm_increaseTime", [17 * 60 * 60 * 24]); //10 days
    let owner = bob.address;

    expect(await Voting.addHackathon(name, description, endDate, votingDate, owner))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(name, description, endDate, votingDate, owner);

    await Voting.printHackathon(0);

    let nameP1 = "Project 1";
    let descriptionP1 = "App for hackathons";
    let contractAddress1 = "address";
    let frontEndURL1 = "https://frontend.com";
    let projectOwner1 = bob.address;

    expect(await Voting.addProject(nameP1, descriptionP1, contractAddress1, frontEndURL1, projectOwner1))
      .to.emit(Voting, "ProjectAdded")
      .withArgs(nameP1, descriptionP1, contractAddress1, frontEndURL1, projectOwner1);

    await Voting.printProject(0, 0);

    let nameP2 = "Project 2";
    let descriptionP2 = "App for voting best food";
    let contractAddress2 = "address food";
    let frontEndURL2 = "https://frontendFood.com";
    let projectOwner2 = andy.address;

    expect(await Voting.addProject(nameP2, descriptionP2, contractAddress2, frontEndURL2, projectOwner2))
      .to.emit(Voting, "ProjectAdded")
      .withArgs(nameP2, descriptionP2, contractAddress2, frontEndURL2, projectOwner2);

    await Voting.printProject(0, 1);

    let nameP3 = "Project 3";
    let descriptionP3 = "App for vote best team";
    let contractAddress3 = "addressBestTeam";
    let frontEndURL3 = "https://frontendBestTeam.com";
    let projectOwner3 = alice.address;

    expect(await Voting.addProject(nameP3, descriptionP3, contractAddress3, frontEndURL3, projectOwner3))
      .to.emit(Voting, "ProjectAdded")
      .withArgs(nameP3, descriptionP3, contractAddress3, frontEndURL3, projectOwner3);

    await Voting.printProject(0, 2);
  });

  it("Governor can set the right vote for users.", async () => {
    expect(await Voting.connect(user).getRightForVote(andy.address, ethers.utils.parseEther("1")))
      .to.emit(Voting, "RightToVoteGiven")
      .withArgs(andy.address, ethers.utils.parseEther("1"));

    expect(await Voting.getBalance(andy.address)).to.be.equals(ethers.utils.parseEther("1"));
  });

  it("It can delegate an user to vote.", async () => {
    await Voting.connect(user).getRightForVote(andy.address, ethers.utils.parseEther("1"));

    console.log(await Voting.getBalance(andy.address));
    console.log(await Voting.getBalance(bob.address));

    expect(await Voting.connect(andy).delegatePerson(bob.address, ethers.utils.parseEther("1")))
      .to.emit(Voting, "DelegatePerson")
      .withArgs(bob.address, ethers.utils.parseEther("1"));

    console.log(await Voting.getBalance(andy.address));
    console.log(await Voting.getBalance(bob.address));

    expect(await Voting.getBalance(andy.address)).to.be.equals(ethers.utils.parseEther("0"));
    expect(await Voting.getBalance(bob.address)).to.be.equals(ethers.utils.parseEther("1"));
  });
});
