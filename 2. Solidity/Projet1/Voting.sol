// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    constructor() Ownable(msg.sender){  }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    mapping(address => Voter) Whitelist;

    function addWhitelist(address _address) public onlyOwner {
        require(Whitelist[_address].isRegistered == false, "This address is already whitelisted");
        Whitelist[_address].isRegistered = true;
    }
}