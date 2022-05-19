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
    uint256 numberOfVotes;
}

struct Voter {
    bool voted;
    uint256 vote;
    address delegate;
}

contract VotingSystem {
    Hackathon[] public hackathons;
    Token public token;
    address public governor;
    uint256 public currentHackathon;

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
        uint256 votes
    );

    event RightToVoteGiven(address _to, uint256 _amount);

    event Voted(address _user, uint256 _teamNumber);

    event DelegatePerson(address _user, uint256 _amount);

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
        governor = msg.sender;
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
        address _owner
    ) public {
        Project memory newProject = Project(_name, _description, _contractAddress, _frontEndURL, _owner, 0);

        hackathons[hackathons.length - 1].projects.push(newProject);

        emit ProjectAdded(_name, _description, _contractAddress, _frontEndURL, _owner, 0);
    }

    //function to give right to vote
    function getRightForVote(address _voterAddress, uint256 _amount) public {
        require(msg.sender == governor, "You must be governor!");
        require(voters[_voterAddress].voted == false, "The user already voted.");
        require(_amount > 0, "The value of amount must be positive.");

        token.mint(_voterAddress, _amount);
        balances[_voterAddress] = token.balanceOf(_voterAddress);

        emit RightToVoteGiven(_voterAddress, _amount);
    }

    //function to delegate
    function delegatePerson(address _user, uint256 _amount) public {
        require(balances[msg.sender] == _amount, "Insuficient funds.");
        require(voters[msg.sender].voted == false, "You can't delegate someone if you already voted.");
        require(voters[msg.sender].delegate == address(0), "You already delegated someone.");

        voters[msg.sender].delegate = _user;
        voters[msg.sender].voted = true;
        balances[_user] += balances[msg.sender];
        balances[msg.sender] = 0;

        emit DelegatePerson(_user, _amount);
    }

    //function for vote
    function vote(uint256 projectNumber) public {
        require(token.balanceOf(msg.sender) > 0, "User must have right to vote.");
        require(voters[msg.sender].voted == false, "The user already voted.");
        require(hackathons[currentHackathon].votingEndDate < block.timestamp, "Voting period is over.");

        Project[] storage projects = hackathons[currentHackathon].projects;
        uint256 votes = balances[msg.sender];

        voters[msg.sender].vote = projectNumber;
        voters[msg.sender].voted = true;
        projects[projectNumber - 1].numberOfVotes = votes;
        balances[msg.sender] = 0;

        emit Voted(msg.sender, projectNumber);
    }

    //function for calculate ranking
    function calculateTopVotedProject() public view returns (uint256) {
        require(hackathons[currentHackathon].votingEndDate > block.timestamp, "Voting period is not over");

        uint256 topVotes;
        uint256 indexOfWinner;
        Project[] storage projects = hackathons[currentHackathon].projects;

        for (uint256 i = 0; i < projects.length; i++) {
            if (projects[i].numberOfVotes > topVotes) {
                topVotes = projects[i].numberOfVotes;
                indexOfWinner = i;
            }
        }

        return indexOfWinner;
    }

    //function to get the Project winner
    function getWinnerProject()
        public
        view
        returns (
            string memory,
            string memory,
            address
        )
    {
        require(hackathons[currentHackathon].endDate > block.timestamp, "Hackathon is still running.");

        uint256 index = calculateTopVotedProject();

        printProject(currentHackathon, index);

        //returnam toate datele despre proiectul castigator?
        return (
            hackathons[currentHackathon].projects[index].projectName,
            hackathons[currentHackathon].projects[index].projectDesctription,
            hackathons[currentHackathon].projects[index].projectOwner
        );
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
        console.log("Votes:", hackathons[hIndex].projects[pIndex].numberOfVotes);
    }

    function getBalance(address _address) public view returns (uint256) {
        return balances[_address];
    }
}
