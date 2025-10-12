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

    constructor() Ownable(msg.sender){
        whitelist[msg.sender].isRegistered = true;
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    WorkflowStatus public currentWorkflowStatus;
    Proposal[] public proposals;

    mapping(address => Voter) whitelist;

    modifier checkRightWorkflow(WorkflowStatus _workflowStatus) {
        require(currentWorkflowStatus == _workflowStatus, "You're not following the right Workflow");
        _;
    }

    modifier isWhitelisted() {
        require(whitelist[msg.sender].isRegistered == true, "You're not Whitelisted");
        _;
    }

    function addWhitelist(address _voter) public onlyOwner {
        require(whitelist[_voter].isRegistered == false, "This address is already whitelisted");
        whitelist[_voter].isRegistered = true;
        emit VoterRegistered(_voter);
    }

    function startProposalRegistration() public checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function endProposalRegistration() public checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVotingSession() public checkRightWorkflow(WorkflowStatus.ProposalsRegistrationEnded) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    function endVotingSession() public checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function votesTallied() public checkRightWorkflow(WorkflowStatus.VotingSessionEnded) {
        currentWorkflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }

    function propose(string memory _proposal) public isWhitelisted checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal({description: _proposal, voteCount: 0}));
        emit ProposalRegistered(proposals.length -1);
    }
}