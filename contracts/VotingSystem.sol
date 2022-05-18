//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./Token.sol";

struct Hackathon {
    string name;
    string description;
    uint256 endDate;
    uint256 votingEndDate;
    address owner;
    Project[] projects;
}

struct Project {
    string projectName;
    string projectDesctription;
    string smartContractAddr;
    string frontEndURL;
    address projectOwner;
    uint256 teamNumber;
    uint256 numberOfVotes;
}

struct Voter {
    uint256 weight;
    bool voted;
    uint256 vote;
}

contract VotingSystem {
    Hackathon[] public hackathons;
    Token public token;

    mapping(address => Voter) public voters;
    mapping(address => uint256) public balances;

    // events
    event HackathonAdded(string _name, string _description, uint256 _endDate, uint256 _votingEnd, address _owner);
    event ProjectAdded(
        string _name,
        string _description,
        string _contractAddress,
        string _frontEndURL,
        address _owner,
        uint256 teamNumber,
        uint256 votes
    );

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    //function to add a hackathon
    function addHackathon(
        string memory _name,
        string memory _description,
        uint256 _endDate,
        uint256 _votingEnd,
        address _ownerAddress
    ) public {
        uint256 newIndex;

        hackathons.push();

        console.log("Length: ", hackathons.length);

        newIndex = hackathons.length - 1;
        hackathons[newIndex].name = _name;
        hackathons[newIndex].description = _description;
        hackathons[newIndex].endDate = _endDate;
        hackathons[newIndex].votingEndDate = _votingEnd;
        hackathons[newIndex].owner = _ownerAddress;

        emit HackathonAdded(_name, _description, _endDate, _votingEnd, _ownerAddress);
    }

    //function to add a project
    function addProject(
        string memory _name,
        string memory _description,
        string memory _contractAddress,
        string memory _frontEndURL,
        address _owner,
        uint256 _teamNumber
    ) public {
        Project memory newProject = Project(
            _name,
            _description,
            _contractAddress,
            _frontEndURL,
            _owner,
            _teamNumber,
            0
        );

        hackathons[hackathons.length - 1].projects.push(newProject);

        emit ProjectAdded(_name, _description, _contractAddress, _frontEndURL, _owner, _teamNumber, 0);
    }

    //function to print hackathon
    function printHackathon(uint256 index) public view {
        console.log("=== Hackathon %d === ", index);
        console.log("Name:", hackathons[index].name);
        console.log("Description:", hackathons[index].description);
        console.log("End date:", hackathons[index].endDate);
        console.log("Voting end date:", hackathons[index].votingEndDate);
        console.log("Owner:", hackathons[index].owner);
    }

    //function to print project
    function printProject(uint256 hIndex, uint256 pIndex) public view {
        console.log("=== Project %d === ", pIndex);
        console.log("Name:", hackathons[hIndex].projects[pIndex].projectName);
        console.log("Description:", hackathons[hIndex].projects[pIndex].projectDesctription);
        console.log("Contract Address:", hackathons[hIndex].projects[pIndex].smartContractAddr);
        console.log("Frontend url:", hackathons[hIndex].projects[pIndex].frontEndURL);
        console.log("Owner:", hackathons[hIndex].projects[pIndex].projectOwner);
        console.log("Team:", hackathons[hIndex].projects[pIndex].teamNumber);
        console.log("Votes:", hackathons[hIndex].projects[pIndex].numberOfVotes);
    }

    //function for vote

    //function to delegate

    //function for calculate ranking

    //function to get the Project winner
}
