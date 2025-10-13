// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
        // New property used with vote delegation
        uint votePower;
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
        // Owner is whitelisted from the start
        whitelist[msg.sender].isRegistered = true;
        whitelist[msg.sender].votePower = 1;
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    // New Event to show removed address from whitelist
    event VoterUnregistered(address voterAddress);

    uint private winningProposalId;
    WorkflowStatus public currentWorkflowStatus;
    Proposal[] public proposals;

    mapping(address => Voter) public whitelist;

    modifier checkRightWorkflow(WorkflowStatus _workflowStatus) {
        require(currentWorkflowStatus == _workflowStatus, "This action isn't available in your current workflow state");
        _;
    }

    modifier isWhitelisted() {
        require(whitelist[msg.sender].isRegistered == true, "You're not Whitelisted");
        _;
    }

    function addWhitelist(address _voter) external onlyOwner checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        require(whitelist[_voter].isRegistered == false, "This address is already whitelisted");
        whitelist[_voter].isRegistered = true;

        // Add vote power to the whitelisted address
        whitelist[_voter].votePower = 1;
        emit VoterRegistered(_voter);
    }

    // Function to remove an address from the whitelist
    function removeWhitelist(address _voter) external onlyOwner checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        require(whitelist[_voter].isRegistered == true, "This address isn't whitelisted");
        whitelist[_voter].isRegistered = false;
        
        // Remove vote power from the address
        whitelist[_voter].votePower = 0;
        emit VoterUnregistered(_voter);
    }

    function startProposalRegistration() external onlyOwner checkRightWorkflow(WorkflowStatus.RegisteringVoters) {
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function endProposalRegistration() external onlyOwner checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        // We need at least 2 proposals in order to Vote
        require(proposals.length > 1, "A vote cannot be started until at least two proposals have been registered.");
        
        currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVotingSession() external onlyOwner checkRightWorkflow(WorkflowStatus.ProposalsRegistrationEnded) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    function endVotingSession() external onlyOwner checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        currentWorkflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function propose(string memory _proposal) external isWhitelisted checkRightWorkflow(WorkflowStatus.ProposalsRegistrationStarted) {
        // Check if Proposal Already Exist or not
        bool _proposalAlreadyExist;
        for(uint i=0; i < proposals.length; i++) {
            if(_isEqual(proposals[i].description, _proposal)) {
                _proposalAlreadyExist = true;
            }
        }
        require(_proposalAlreadyExist == false, "Sorry but your proposal already exist");

        proposals.push(Proposal({description: _proposal, voteCount: 0}));
        emit ProposalRegistered(proposals.length -1);
    }

    function vote(uint _voteProposalId) external isWhitelisted checkRightWorkflow(WorkflowStatus.VotingSessionStarted) {
        // Check if whitelist member who delegated his vote tries to vote
        require(whitelist[msg.sender].votePower > 0, "You delegated your vote so you can't vote yourself");

        require(whitelist[msg.sender].hasVoted == false, "You already voted!");
        require(_voteProposalId < proposals.length, "You tried to vote for a proposal who doesn't exist");

        // Add the vote power from the whitelisted address to the proposal vote count
        proposals[_voteProposalId].voteCount += whitelist[msg.sender].votePower;
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = _voteProposalId;
        emit Voted(msg.sender, _voteProposalId);
    }

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

    function getWinner() external view returns(uint) {
        require(currentWorkflowStatus == WorkflowStatus.VotesTallied, "The votes have not yet been counted");
        return winningProposalId;
    }

    // Function used to compare 2 string if they're the same or not
    function _isEqual(string memory _string1, string memory _string2) private pure returns(bool) {
        return(keccak256(abi.encodePacked(_string1)) == keccak256(abi.encodePacked(_string2)));
    }

    // Function to delegate your vote power to another whitelisted address
    function delegateVote(address _delegatedTo) external isWhitelisted {
        if(currentWorkflowStatus != WorkflowStatus.ProposalsRegistrationStarted && currentWorkflowStatus != WorkflowStatus.ProposalsRegistrationEnded && currentWorkflowStatus != WorkflowStatus.RegisteringVoters) {
            revert("It's too late to delegate your vote to someone");
        }
        require(whitelist[_delegatedTo].isRegistered == true, "This address is not whitelisted, so you can't delegate your vote to him");
        whitelist[_delegatedTo].votePower += whitelist[msg.sender].votePower;
        whitelist[msg.sender].votePower = 0;
    }
}