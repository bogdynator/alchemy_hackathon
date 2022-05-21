//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
import "./TokenVote.sol";

struct Organization {
    string name;
    string description;
    TokenVote token;
    uint256 hackathonNr;
}

struct Hackathon {
    string name;
    string description;
    uint256 startDate;
    uint256 endDate;
    uint256 reward;
    uint256[] winners;
    uint256 projectsNr;
}

struct Project {
    string name;
    string url;
    address projectAddress;
    address[] contributors;
    uint256 votes;
}
