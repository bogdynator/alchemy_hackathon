//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
import "./TokenVote.sol";

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
