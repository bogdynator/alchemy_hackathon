//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

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

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addOrganization(
        string calldata _name,
        string calldata _description,
        string calldata _tokenName,
        string calldata _tokenSymbol,
        address[] calldata admins
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (address) {
        require(admins.length <= 5, "To many admins");
        organizationIdCounter.increment();
        uint256 currentTokenId = organizationIdCounter.current();
        uint256[] memory hackatons;
        TokenVote token = new TokenVote(_tokenName, _tokenSymbol);

        organizations[currentTokenId] = Organization(_name, _description, admins, hackatons, token);

        return address(token);
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
        organizationIdCounter.increment();
        uint256 currentTokenId = organizationIdCounter.current();

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
    }

    function addProject(
        uint256 _hackathonId,
        address[] calldata contributors,
        string calldata _name,
        string calldata _url
    ) external {
        projectsIdCounter.increment();
        uint256 currentTokenId = projectsIdCounter.current();

        projects[_hackathonId][currentTokenId] = Project(_name, _url, contributors, 0);
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
        // ca nu a votat
        require(voted[_projectId][msg.sender] == 0, "Already voted");
        projects[_hackathonId][_projectId].votes += nrOfVotes;
        // block the votes
        voted[_projectId][msg.sender] = 1;
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
        voted[_projectId][_ownerOfTokens] = 1;
    }

    function executeReward(uint256 _hackathonId, address[] calldata winners) external adminRequired(_hackathonId) {
        require(hackathons[_hackathonId].voteEnd < block.timestamp, "Voting is not complete");
        uint256 rewardPerWinner = hackathons[_hackathonId].reward / winners.length;
        for (uint256 i; i < winners.length; i++) {
            rewards[winners[i]] += rewardPerWinner;
        }
    }
}
