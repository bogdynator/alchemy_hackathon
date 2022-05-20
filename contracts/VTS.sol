//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import "./TokenVote.sol";

contract VTS is AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter public organizationIdCounter;
    Counters.Counter public hackathonsIdCounter;
    Counters.Counter public projectsIdCounter;

    struct Organization {
        string name;
        string description;
        address[] admins;
        uint256[] hackathons;
        TokenVote token;
    }

    struct Hackathon {
        string name;
        string description;
        uint256 startDate;
        uint256 endDate;
        uint256 reward;
        uint256 voteStart;
        uint256 voteEnd;
    }

    struct Project {
        string name;
        string url;
        address[] contributors;
        uint256 votes;
    }

    mapping(uint256 => Organization) public organizations;
    mapping(uint256 => mapping(address => uint256)) public voted;
    mapping(uint256 => mapping(address => uint256)) public voters;
    mapping(uint256 => Hackathon) public hackathons;
    mapping(uint256 => mapping(uint256 => Project)) public projects;
    mapping(address => uint256) public rewards;
    mapping(uint256 => uint256) numberOfProjectsPerHack;

    event OrganizationAdded(string name, string description, string tokenName, string tokenSymbol);

    event VoterAdded(address _voter, uint256 _organizationId, uint256 _amount);

    event HackathonAdded(
        uint256 _organizationId,
        string _name,
        string _description,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _reward,
        uint256 _voteStartDate,
        uint256 _voteEndDate
    );

    event ProjectAdded(uint256 _hackathonId, string _name, string _url);

    event Voted(uint256 _organizationId, uint256 _hackathonId, uint256 _projectId);

    event VotedByDelegate(uint256 _organizationId, uint256 _hackathonId, uint256 _projectId, address _ownerOfTokens);

    constructor() {}

    function addOrganization(
        string calldata _name,
        string calldata _description,
        string calldata _tokenName,
        string calldata _tokenSymbol,
        address[] calldata admins
    ) external {
        require(admins.length <= 5, "Too many admins");
        require(admins.length % 2 == 0, "Any organizations must have odd number of admins.");
        organizationIdCounter.increment();
        uint256 currentTokenId = organizationIdCounter.current();
        uint256[] memory hackatons;
        TokenVote token = new TokenVote(_tokenName, _tokenSymbol);

        organizations[currentTokenId] = Organization(_name, _description, admins, hackatons, token);

        emit OrganizationAdded(_name, _description, _tokenName, _tokenSymbol);
    }

    modifier adminRequired(uint256 _organizationId) {
        bool isAdmin = false;
        address[] memory admins = organizations[_organizationId].admins;
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

        emit VoterAdded(_voter, _organizationId, _amount);
    }

    function addHackathon(
        uint256 _organizationId,
        string calldata _name,
        string calldata _description,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _reward,
        uint256 _voteStartDate,
        uint256 _voteEndDate
    ) external adminRequired(_organizationId) {
        hackathonsIdCounter.increment();
        uint256 currentTokenId = hackathonsIdCounter.current();

        // here we should add input validation on dates
        hackathons[currentTokenId] = Hackathon(
            _name,
            _description,
            _startDate,
            _endDate,
            _reward,
            _voteStartDate,
            _voteEndDate
        );
        organizations[_organizationId].hackathons.push(currentTokenId);

        emit HackathonAdded(
            _organizationId,
            _name,
            _description,
            _startDate,
            _endDate,
            _reward,
            _voteStartDate,
            _voteEndDate
        );
    }

    function addProject(
        uint256 _hackathonId,
        address[] calldata contributors,
        string calldata _name,
        string calldata _url
    ) external {
        require(hackathons[_hackathonId].endDate > block.timestamp, "Hackathon is over.");
        projectsIdCounter.increment();
        uint256 currentTokenId = projectsIdCounter.current();

        projects[_hackathonId][currentTokenId] = Project(_name, _url, contributors, 0);

        numberOfProjectsPerHack[_hackathonId] += 1;

        emit ProjectAdded(_hackathonId, _name, _url);
    }

    function vote(
        uint256 _organizationId,
        uint256 _hackathonId,
        uint256 _projectId
    ) external {
        require(hackathons[_hackathonId].voteEnd > block.timestamp, "Voting is complete");

        uint256 nrOfVotes = organizations[_organizationId].token.getVotes(msg.sender);
        uint256 nrOfTokens = organizations[_organizationId].token.balanceOf(msg.sender);

        require(nrOfVotes == nrOfTokens, "Sender is not the owner of tokens");
        require(nrOfVotes > 0, "Not enought votes available");

        require(voted[_hackathonId][msg.sender] == 0, "Already voted");

        projects[_hackathonId][_projectId].votes += nrOfVotes;

        voted[_hackathonId][msg.sender] = _projectId;

        emit Voted(_organizationId, _hackathonId, _projectId);
    }

    function voteByDelegate(
        uint256 _organizationId,
        uint256 _hackathonId,
        uint256 _projectId,
        address _ownerOfTokens
    ) external {
        require(hackathons[_hackathonId].voteEnd > block.timestamp, "Voting is complete");
        TokenVote token = organizations[_organizationId].token;
        uint256 nrOfVotes = organizations[_organizationId].token.getVotes(msg.sender);
        require(token.delegates(_ownerOfTokens) == msg.sender, "msg.sender is not a delegatee of owner");
        require(nrOfVotes > 0, "Not enought votes available");
        // ca nu a votat
        require(voted[_projectId][_ownerOfTokens] == 0, "Already voted");
        projects[_hackathonId][_projectId].votes += nrOfVotes;
        // block the votes
        voted[_projectId][_ownerOfTokens] = _projectId;
    }

    function calculateWinners(uint256 _hackathonId)
        external
        view
        adminRequired(_hackathonId)
        returns (uint256[] memory)
    {
        require(_hackathonId > 0, "Hackathon must exists.");
        uint256 winnerVotes;
        uint256[] memory indexOfWinner = new uint256[](numberOfProjectsPerHack[_hackathonId]);
        for (uint256 i = 0; i < numberOfProjectsPerHack[_hackathonId]; i++) {
            if (winnerVotes < projects[_hackathonId][i].votes) {
                winnerVotes = projects[_hackathonId][i].votes;
                indexOfWinner[i] = i;
            }
        }
        return indexOfWinner;
    }

    function executeReward(uint256 _hackathonId, address[] calldata winners) external adminRequired(_hackathonId) {
        require(hackathons[_hackathonId].voteEnd < block.timestamp, "Voting is not complete");
        uint256 rewardPerWinner = hackathons[_hackathonId].reward / winners.length;
        for (uint256 i; i < winners.length; i++) {
            rewards[winners[i]] += rewardPerWinner;
        }
    }
}
