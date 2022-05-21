//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Structs.sol";

import "hardhat/console.sol";

contract VTS is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter public organizationIdCounter;

    mapping(uint256 => Organization) public organizations;
    mapping(uint256 => address[]) public organizationAdmins;
    uint256 public organizationsId;
    mapping(uint256 => mapping(address => uint256)) public voted;
    mapping(uint256 => mapping(address => uint256)) public voters;
    mapping(uint256 => mapping(uint256 => Hackathon)) public hackathons;
    mapping(uint256 => mapping(uint256 => Project)) public projects;
    mapping(address => uint256) public rewards;

    event AddOrganization();
    event AddHackathon();
    event AddProject(string name, address[] contributors, uint256 projectNumber);
    event AddVoter(uint256 organizatonId, address voter, uint256 amount);
    event AddAdminOrganization();
    event Vote();

    event Winner(uint256 _hackathonId);

    constructor() {}

    function addOrganization(
        string calldata _name,
        string calldata _description,
        string calldata _tokenName,
        string calldata _tokenSymbol,
        address[] calldata admins
    ) external {
        require(admins.length <= 5, "To many admins");
        organizationIdCounter.increment();
        uint256 currentTokenId = organizationIdCounter.current();
        TokenVote token = new TokenVote(_tokenName, _tokenSymbol);

        emit AddOrganization();
        organizations[currentTokenId] = Organization(_name, _description, token, 0);
        organizationAdmins[currentTokenId] = admins;
    }

    modifier adminRequired(uint256 _organizationId) {
        bool isAdmin = false;
        address[] memory admins = organizationAdmins[_organizationId];
        for (uint256 i; i < admins.length; i++) {
            if (msg.sender == admins[i]) {
                isAdmin = true;
            }
        }
        require(isAdmin, "Required admin right");
        _;
    }

    function addVoter(
        address _voter,
        uint256 _organizationId,
        uint256 _amount
    ) external adminRequired(_organizationId) {
        require(voters[_organizationId][_voter] == 0, "Voter has been added in the past");
        voters[_organizationId][_voter] = 1;
        organizations[_organizationId].token.mint(_voter, _amount);
        emit AddVoter(_organizationId, _voter, _amount);
    }

    function addHackathon(
        uint256 _organizationId,
        string calldata _name,
        string calldata _description,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _reward
    ) external adminRequired(_organizationId) {
        // here we should add input validation on dates
        uint256[] memory winners = new uint256[](1);
        winners[0] = 0;
        organizations[_organizationId].hackathonNr += 1;
        uint256 hackNr = organizations[_organizationId].hackathonNr;
        hackathons[_organizationId][hackNr] = Hackathon(_name, _description, _startDate, _endDate, _reward, winners, 0);
        emit AddHackathon();
    }

    function addProject(
        uint256 _organizationId,
        uint256 _hackathonId,
        address _projectAddress,
        address[] calldata contributors,
        string calldata _name,
        string calldata _url
    ) external {
        hackathons[_organizationId][_hackathonId].projectsNr += 1;
        projects[_hackathonId][hackathons[_organizationId][_hackathonId].projectsNr] = Project(
            _name,
            _url,
            _projectAddress,
            contributors,
            0
        );
        emit AddProject(_name, contributors, hackathons[_organizationId][_hackathonId].projectsNr);
    }

    function vote(
        uint256 _organizationId,
        uint256 _hackathonId,
        uint256 _projectId
    ) external {
        require(hackathons[_organizationId][_hackathonId].endDate > block.timestamp, "Voting is complete");
        uint256 nrOfVotes = organizations[_organizationId].token.getVotes(msg.sender);
        uint256 nrOfTokens = organizations[_organizationId].token.balanceOf(msg.sender);

        require(nrOfVotes == nrOfTokens, "Sender is not the owner of tokens");
        require(nrOfVotes > 0, "Not enought votes available");
        require(voted[_hackathonId][msg.sender] == 0, "Already voted");

        projects[_hackathonId][_projectId].votes += nrOfVotes;
        voted[_hackathonId][msg.sender] = _projectId;
        uint256 currentProjNrOfVotes = projects[_hackathonId][_projectId].votes;
        if (hackathons[_organizationId][_hackathonId].winners[0] == currentProjNrOfVotes) {
            hackathons[_organizationId][_hackathonId].winners.push(_projectId);
        } else {
            if (hackathons[_organizationId][_hackathonId].winners[0] < currentProjNrOfVotes) {
                hackathons[_organizationId][_hackathonId].winners = [currentProjNrOfVotes];
            }
        }
        emit Vote();
    }

    function voteByDelegate(
        uint256 _organizationId,
        uint256 _hackathonId,
        uint256 _projectId,
        address _ownerOfTokens
    ) external {
        require(hackathons[_organizationId][_hackathonId].endDate > block.timestamp, "Voting is complete");
        TokenVote token = organizations[_organizationId].token;
        uint256 nrOfVotes = organizations[_organizationId].token.getVotes(msg.sender);
        require(token.delegates(_ownerOfTokens) == msg.sender, "msg.sender is not a delegatee of owner");
        require(nrOfVotes > 0, "Not enought votes available");

        require(voted[_hackathonId][msg.sender] == 0, "Already voted");
        projects[_hackathonId][_projectId].votes += nrOfVotes;

        voted[_hackathonId][msg.sender] = _projectId;
    }

    function executeReward(uint256 _hackathonId, uint256 _organizationId) external adminRequired(_hackathonId) {
        require(hackathons[_organizationId][_hackathonId].endDate < block.timestamp, "Voting is not complete");
        uint256[] memory projectWinners = hackathons[_organizationId][_hackathonId].winners;
        uint256 rewardPerProjectWinner = hackathons[_organizationId][_hackathonId].reward / projectWinners.length;

        for (uint256 i; i < projectWinners.length; i++) {
            address[] memory projectContributors = projects[_hackathonId][projectWinners[i]].contributors;
            for (uint256 j; j < projectContributors.length; j++)
                rewards[projectContributors[j]] += rewardPerProjectWinner / projectContributors.length;
        }
    }

    function getHackathon(uint256 _hackathonId, uint256 _organizationId) external view returns (Hackathon memory) {
        return hackathons[_organizationId][_hackathonId];
    }

    function getOrganizationHackathons(uint256 _organizationId) external view returns (Hackathon[] memory) {
        uint256 hackNr = organizations[_organizationId].hackathonNr;
        Hackathon[] memory hacks = new Hackathon[](hackNr);
        for (uint256 i; i < organizations[_organizationId].hackathonNr; i++) {
            hacks[i] = hackathons[_organizationId][i + 1];
        }
        return hacks;
    }
}
