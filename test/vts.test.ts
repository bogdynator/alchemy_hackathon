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
    await Token.mint(bob.address, 100);
    console.log(await Token.balanceOf(bob.address));
    console.log(await Token.name());
    await Voting.addHackathon(1, "hack", "desc", 1653033263, 1659646800, 1000, 1653033263, 1659646800);
    await Voting.addProject(1, ["0xc20276346b47E9D7d7d558F0387D147f26923Da6"], "Proj1", "https://currentmillis.com/");
    await Voting.addVoter("0xc20276346b47E9D7d7d558F0387D147f26923Da6", 1, 1000);
    await Voting.vote(1, 1, 1);
    expect(await Voting.voted("1", user.address)).to.be.equal(1);
  });
});
