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

    constructor() Ownable(msg.sender) {
        whitelist[msg.sender].isRegistered = true;
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    uint public winningProposalId;
    WorkflowStatus public currentWorkflowStatus;
    Proposal[] public proposals;

    mapping(address => Voter) public whitelist;

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

    function startProposalRegistration() public onlyOwner checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function endProposalRegistration() public onlyOwner checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVotingSession() public onlyOwner checkRightWorkflow(WorkflowStatus.ProposalsRegistrationEnded) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    function endVotingSession() public onlyOwner checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function propose(string memory _proposal) public isWhitelisted checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal({description: _proposal, voteCount: 0}));
        emit ProposalRegistered(proposals.length -1);
    }

    function vote(uint _voteProposalId) public isWhitelisted checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        require(whitelist[msg.sender].hasVoted == false, "You already voted!");
        require(_voteProposalId < proposals.length, "You tried to vote for a proposal who doesn't exist");
        proposals[_voteProposalId].voteCount += 1;
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = _voteProposalId;
        emit Voted(msg.sender, _voteProposalId);
    }

    function countVote() public onlyOwner checkRightWorkflow(WorkflowStatus.VotingSessionEnded) {
        uint mostVotedProposalId;
        uint mostVote;

        for(uint i=0; i < proposals.length; i++) {
            if(proposals[i].voteCount > mostVote) {
                mostVote = proposals[i].voteCount;
                mostVotedProposalId = i;
            }
        }

        currentWorkflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
        winningProposalId = mostVotedProposalId;
    }
}