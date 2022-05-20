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

  it("add org", async () => {
    await Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]);
    let org = await Voting.organizations(1);

    Token = (await ethers.getContractAt("TokenVote", org.token)) as TokenVote;
    await Token.mint(bob.address, 100);
    console.log(await Token.balanceOf(bob.address));
    console.log(await Token.name());
  });
  it("vote", async () => {
    await Voting.addOrganization("org1", "description1", "tokenOrg", "TORG1", [user.address, bob.address]);
    let org = await Voting.organizations(1);

    Token = (await ethers.getContractAt("TokenVote", org.token)) as TokenVote;
    console.log(await Token.name());
    await Voting.addHackathon(1, "hack", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800);
    await Voting.addProject(1, [user.address], "Proj1", "https://currentmillis.com/");
    await expect(Voting.addVoter(user.address, 1, 1000))
      .to.emit(Token, "Transfer")
      .withArgs(ethers.constants.AddressZero, user.address, 1000);
    expect(await Token.balanceOf(user.address)).to.be.equal(1000);
    await Token.delegate(user.address);
    expect(await Token.getVotes(user.address)).to.be.equal(1000);
    await Voting.connect(user).vote(1, 1, 1);
    expect(await Voting.voted("1", user.address)).to.be.equal(1);
  });
});
