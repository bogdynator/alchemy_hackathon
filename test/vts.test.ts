import { messagePrefix } from "@ethersproject/hash";
import { expect } from "chai";
import { Console } from "console";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { userInfo } from "os";

import { TokenVote, TokenVote__factory, VTS, VTS__factory } from "../typechain";

describe("Test Voting System", async () => {
  let VotingFactory: any;
  let Voting: VTS;
  let TokenFactory: any;
  let Token: TokenVote;

  let user: any;
  let andy: any;
  let bob: any;
  let alice: any;

  before(async () => {
    [user, bob, andy, alice] = await ethers.getSigners();
    VotingFactory = (await ethers.getContractFactory("VTS", user)) as VTS__factory;
  });

  beforeEach(async () => {
    Voting = await VotingFactory.deploy();
  });

  it("It was deployed correctly", async () => {});

  it("I can add an organization.", async () => {
    await expect(Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org1", "description1", "tokenOrg", "TORG1");

    let org = await Voting.organizations(1);

    Token = (await ethers.getContractAt("TokenVote", org.token)) as TokenVote;

    expect(await Token.name()).to.be.equal("tokenOrg");
  });

  it("It can add org, hack, projects", async () => {
    await expect(Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org1", "description1", "tokenOrg", "TORG1");

    await expect(Voting.addOrganization("org2", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org2", "description1", "tokenOrg", "TORG1");

    await expect(Voting.addOrganization("org3", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org3", "description1", "tokenOrg", "TORG1");

    let org1 = await Voting.organizations(1);
    let org2 = await Voting.organizations(2);
    let org3 = await Voting.organizations(3);

    await expect(Voting.addHackathon(1, "hack1", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(1, "hack1", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800);

    await expect(Voting.addHackathon(1, "hack2", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(1, "hack2", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800);

    await expect(
      Voting.addProject(1, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj1", "https://currentmillis.com/"),
    )
      .to.emit(Voting, "ProjectAdded")
      .withArgs(1, "Proj1", "https://currentmillis.com/");

    await expect(
      Voting.addProject(1, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj2", "https://currentmillis.com/"),
    )
      .to.emit(Voting, "ProjectAdded")
      .withArgs(1, "Proj2", "https://currentmillis.com/");

    await expect(
      Voting.addProject(2, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj3", "https://currentmillis.com/"),
    )
      .to.emit(Voting, "ProjectAdded")
      .withArgs(2, "Proj3", "https://currentmillis.com/");

    await expect(
      Voting.addProject(2, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj4", "https://currentmillis.com/"),
    )
      .to.emit(Voting, "ProjectAdded")
      .withArgs(2, "Proj4", "https://currentmillis.com/");

    await expect(
      Voting.addProject(2, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj5", "https://currentmillis.com/"),
    )
      .to.emit(Voting, "ProjectAdded")
      .withArgs(2, "Proj5", "https://currentmillis.com/");
  });

  it("It can add a voter.", async () => {
    await expect(Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org1", "description1", "tokenOrg", "TORG1");

    let org = await Voting.organizations(1);

    Token = (await ethers.getContractAt("TokenVote", org.token)) as TokenVote;

    expect(await Token.name()).to.be.equals("tokenOrg");

    await expect(Voting.addHackathon(1, "hack1", "desc", 1653033263, 1659646800, 1000, 1653033263, 1653220793))
      .to.emit(Voting, "HackathonAdded")
      .withArgs(1, "hack1", "desc", 1653033263, 1659646800, 1000, 1653033263, 1653220793);

    await expect(
      Voting.addProject(1, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj1", "https://currentmillis.com/"),
    )
      .to.emit(Voting, "ProjectAdded")
      .withArgs(1, "Proj1", "https://currentmillis.com/");

    await expect(Voting.addVoter(user.address, 1, 1000)).to.emit(Voting, "VoterAdded").withArgs(user.address, 1, 1000);
    expect(await Token.balanceOf(user.address)).to.be.equal(1000);

    await Token.delegate(user.address);
    expect(await Token.getVotes(user.address)).to.be.equals(1000);
  });

  it("It can vote.", async () => {
    await expect(Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org1", "description1", "tokenOrg", "TORG1");
    let org = await Voting.organizations(1);

    Token = (await ethers.getContractAt("TokenVote", org.token)) as TokenVote;

    await Voting.addHackathon(1, "hack", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800);
    await Voting.addProject(1, [user.address], "Proj1", "https://currentmillis.com/");

    await expect(Voting.addVoter(user.address, 1, 1000))
      .to.emit(Token, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1000);

    expect(await Token.balanceOf(user.address)).to.be.equal(1000);

    await Token.delegate(user.address);
    expect(await Token.getVotes(user.address)).to.be.equal(1000);

    await expect(Voting.connect(user).vote(1, 1, 1)).to.emit(Voting, "Voted").withArgs(1, 1, 1);

    expect(await Voting.voted("1", user.address)).to.be.equal(1);
  });

  it("It can vote by delegate", async () => {});

  it("It can get the winner", async () => {
    await expect(Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]))
      .to.emit(Voting, "OrganizationAdded")
      .withArgs("org1", "description1", "tokenOrg", "TORG1");
    let org = await Voting.organizations(1);

    Token = (await ethers.getContractAt("TokenVote", org.token)) as TokenVote;

    await Voting.addHackathon(1, "hack", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800);
    await Voting.addProject(1, [user.address], "Proj1", "https://currentmillis1.com/");
    await Voting.addProject(1, [andy.address], "Proj2", "https://currentmillis2.com/");
    await Voting.addProject(1, [bob.address], "Proj3", "https://currentmillis3.com/");

    await expect(Voting.addVoter(user.address, 1, 1000))
      .to.emit(Token, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1000);

    await Token.delegate(user.address);
    expect(await Token.getVotes(user.address)).to.be.equal(1000);

    await expect(Voting.connect(user).vote(1, 1, 2)).to.emit(Voting, "Voted").withArgs(1, 1, 2);

    expect(await Voting.voted("1", user.address)).to.be.equal(2);

    await expect(Voting.addVoter(andy.address, 1, 1000))
      .to.emit(Token, "Transfer")
      .withArgs(ethers.constants.AddressZero, andy.address, 1000);

    await Token.delegate(andy.address);
    expect(await Token.getVotes(andy.address)).to.be.equal(1000);

    await expect(Voting.connect(andy).vote(1, 1, 2)).to.emit(Voting, "Voted").withArgs(1, 1, 2);

    expect(await Voting.voted("1", andy.address)).to.be.equal(2);

    await expect(Voting.addVoter(bob.address, 1, 1000))
      .to.emit(Token, "Transfer")
      .withArgs(ethers.constants.AddressZero, bob.address, 1000);

    await Token.delegate(bob.address);
    expect(await Token.getVotes(bob.address)).to.be.equal(1000);

    await expect(Voting.connect(bob).vote(1, 1, 2)).to.emit(Voting, "Voted").withArgs(1, 1, 2);

    expect(await Voting.voted("1", bob.address)).to.be.equal(2);

    await expect(Voting.calculateWinners(1)).to.emit(Voting, "Winner").withArgs(1);

    await Voting.printWinner(1);
  });
});
