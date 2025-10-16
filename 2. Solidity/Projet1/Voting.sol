// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

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

    constructor() Ownable(msg.sender) {}

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    uint private winningProposalId;
    WorkflowStatus public currentWorkflowStatus;
    Proposal[] public proposals;

    // All the Whitelisted Addresses
    mapping(address => Voter) public whitelist;

    // Modifier - check if we are in the right Workflow Status in order to execute the following function
    modifier checkRightWorkflow(WorkflowStatus _workflowStatus) {
        require(currentWorkflowStatus == _workflowStatus, "This action isn't available in your current workflow state");
        _;
    }

    // Modifier - check if the msg.sender is Whitelisted
    modifier isWhitelisted() {
        require(whitelist[msg.sender].isRegistered == true, "You're not Whitelisted");
        _;
    }

    // Admin
    // Add an address to the whitelist during the "RegisteringVoters" phase
    function addWhitelist(address _voter) external onlyOwner checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        require(whitelist[_voter].isRegistered == false, "This address is already whitelisted");
        whitelist[_voter].isRegistered = true;
        emit VoterRegistered(_voter);
    }

    // Admin
    // Start the "ProposalRegistration" phase only if we are currently in the "RegisteringVoters" phase
    function startProposalRegistration() external onlyOwner checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    // Admin
    // Start the "ProposalRegistration" phase only if we are currently in the "RegisteringVoters" phase
    function endProposalRegistration() external onlyOwner checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    // Admin
    // Start the "VotingSessionStarted" phase only if we are currently in the "ProposalsRegistrationEnded" phase
    function startVotingSession() external onlyOwner checkRightWorkflow(WorkflowStatus.ProposalsRegistrationEnded) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    // Admin
    // Start the "VotingSessionEnded" phase only if we are currently in the "VotingSessionStarted" phase
    function endVotingSession() external onlyOwner checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    // Whitelisted Address
    // Add a proposal only during the "ProposalsRegistrationStarted" phase
    function addProposal(string memory _proposal) external isWhitelisted checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal({description: _proposal, voteCount: 0}));
        emit ProposalRegistered(proposals.length -1);
    }

    // Whitelisted Address
    // Vote for a proposal only during the "VotingSessionStarted" phase
    function addVote(uint _voteProposalId) external isWhitelisted checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        require(whitelist[msg.sender].hasVoted == false, "You already voted!");
        require(_voteProposalId < proposals.length, "You tried to vote for a proposal who doesn't exist");
        proposals[_voteProposalId].voteCount += 1;
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = _voteProposalId;
        emit Voted(msg.sender, _voteProposalId);
    }

    // Admin
    // Count vote only during the "VotingSessionEnded" phase and pass to the "VotesTallied" phase
    function countVote() external onlyOwner checkRightWorkflow(WorkflowStatus.VotingSessionEnded) {
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


    // EveryOne
    // Return the winning Proposal
    function getWinner() external view returns(string memory) {
        require(currentWorkflowStatus == WorkflowStatus.VotesTallied, "The votes have not yet been counted");
        return proposals[winningProposalId].description;
    }
}