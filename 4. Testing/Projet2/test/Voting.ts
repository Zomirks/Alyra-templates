import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

async function setUpSmartContract() {
  const [owner] = await ethers.getSigners();
  const voting = await ethers.deployContract("Voting", [owner.address]);
  
  return { voting, owner };
}

describe("Voting contract", function () {
    let voting : any;
    let owner : any;

    beforeEach(async () => {
        ({ voting, owner } = await setUpSmartContract());
    });

    describe("Contract is Deployed", function () {
        it("winningProposalID should be 0", async function() {
            expect(await voting.winningProposalID()).to.equal(0n);
        });

        it("getVoter(owner.address) should return true", async function() {
            const [isRegistered] = await voting.getVoter(owner.address);
            expect(isRegistered).to.equal(true);
        });

        it("proposalsArray[0] should be revertedWithPanic(0x32)", async function() {
            await expect(voting.getOneProposal(0)).to.be.revertedWithPanic(0x32);
        });

        it("WorkflowStatus should be 0", async function() {
            expect(await voting.workflowStatus()).to.equal(0n);
        });
    });

    describe("Registering Voters", function () {
        it("Non-owner trying to register a voter should be revertedWith", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.connect(addr1).addVoter(addr1.address)).to.be.revertedWithCustomError(voting, "OwnableUnauthorizedAccount").withArgs(addr1.address);
        });

        it("Owner registering a voter should set voter as registered", async function() {
            const [, addr1] = await ethers.getSigners();
            await voting.addVoter(addr1.address);
            const [isRegistered] = await voting.getVoter(addr1.address);
            expect(isRegistered).to.equal(true);
        });

        it("Owner registering a voter should emit the VoterRegistered event", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.addVoter(addr1.address)).to.emit(voting, "VoterRegistered").withArgs(addr1.address);
        });

        it("Registering the same voter twice should be revertedWithCustomError 'Already registered'", async function() {
            const [, addr1] = await ethers.getSigners();
            await voting.addVoter(addr1.address);
            await expect(voting.addVoter(addr1.address)).to.be.revertedWith("Already registered");
        });

        it("addProposal() should revert with 'Proposals are not allowed yet'", async function() {
            await expect(voting.addProposal("My Proposal")).to.be.revertedWith("Proposals are not allowed yet");
        });

        it("tallyVotes() should revert with 'Current status is not voting session ended'", async function() {
            await expect(voting.tallyVotes()).to.be.revertedWith("Current status is not voting session ended");
        });

        it("startProposalsRegistering should emit WorkflowStatusChange event", async function() {
            expect(await voting.startProposalsRegistering()).to.emit(voting, "WorkflowStatusChange").withArgs(0, 1);
        });
    });

    describe("Proposals Registration Started", function () {
        beforeEach(async () => {
            await voting.startProposalsRegistering();
        });

        it("Starting proposal registration should change workflowStatus to 1", async function() {
            expect(await voting.workflowStatus()).to.equal(1n);
        });

        it("Starting proposal registration should add 'GENESIS' proposal", async function() {
            const proposal = await voting.getOneProposal(0);
            expect(proposal.description).to.equal('GENESIS');
            expect(await voting.workflowStatus()).to.equal(1n);
        });

        it("addVoter() should revert with 'Voters registration is not open yet'", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.addVoter(addr1.address)).to.be.revertedWith("Voters registration is not open yet");
        });

        it("addProposal() should revert with 'You're not a voter'", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.connect(addr1).addProposal("My Proposal")).to.be.revertedWith("You're not a voter");
        });

        it("addProposal() should add a proposal in proposalsArray", async function() {
            const proposalDesc = "My Proposal";
            await voting.addProposal(proposalDesc);
            const proposal = await voting.getOneProposal(1);
            expect(proposal.description).to.equal(proposalDesc);
            expect(proposal.voteCount).to.equal(0n);
        });

        it("addProposal() shouldn't add an empty proposal", async function() {
            await expect(voting.addProposal("")).to.be.revertedWith("Vous ne pouvez pas ne rien proposer");
        });

        it("addProposal() should emit ProposalRegistered event", async function() {
            await expect(voting.addProposal("My Proposal 2")).to.emit(voting, "ProposalRegistered").withArgs(1n);
        });

        it("tallyVotes() should revert with 'Current status is not voting session ended'", async function() {
            await expect(voting.tallyVotes()).to.be.revertedWith("Current status is not voting session ended");
        });

        it("endProposalsRegistering should emit WorkflowStatusChange event", async function() {
            expect(await voting.endProposalsRegistering()).to.emit(voting, "WorkflowStatusChange").withArgs(1, 2);
        });
    });

    describe("Proposals Registration Ended", function () {
        beforeEach(async () => {
            await voting.startProposalsRegistering();
            await voting.endProposalsRegistering();
        });

        it("Ending proposal registration should change workflowStatus to 2", async function() {
            expect(await voting.workflowStatus()).to.equal(2n);
        });

        it("startProposalsRegistering should revertWith 'Registering proposals cant be started now'", async function() {
            await expect(voting.startProposalsRegistering()).to.revertedWith("Registering proposals cant be started now");
        });

        it("addVoter() should revert with 'Voters registration is not open yet'", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.addVoter(addr1.address)).to.be.revertedWith("Voters registration is not open yet");
        });

        it("addProposal() should revert with 'Proposals are not allowed yet'", async function() {
            await expect(voting.addProposal("My Proposal")).to.be.revertedWith("Proposals are not allowed yet");
        });

        it("tallyVotes() should revert with 'Current status is not voting session ended'", async function() {
            await expect(voting.tallyVotes()).to.be.revertedWith("Current status is not voting session ended");
        });

        it("startVotingSession should emit WorkflowStatusChange event", async function() {
            expect(await voting.startVotingSession()).to.emit(voting, "WorkflowStatusChange").withArgs(2, 3);
        });
    });

    describe("Voting Session Started", function () {
        beforeEach(async () => {
            await voting.startProposalsRegistering();
            await voting.addProposal("Proposal 1");
            await voting.addProposal("Proposal 2");
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
        });

        it("Starting Voting Session should change workflowStatus to 3", async function() {
            expect(await voting.workflowStatus()).to.equal(3n);
        });

        it("endProposalsRegistering should revertWith 'Registering proposals havent started yet'", async function() {
            await expect(voting.endProposalsRegistering()).to.revertedWith("Registering proposals havent started yet");
        });

        it("addVoter() should revert with 'Voters registration is not open yet'", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.addVoter(addr1.address)).to.be.revertedWith("Voters registration is not open yet");
        });

        it("addProposal() should revert with 'Proposals are not allowed yet'", async function() {
            await expect(voting.addProposal("My Proposal")).to.be.revertedWith("Proposals are not allowed yet");
        });

        it("tallyVotes() should revert with 'Current status is not voting session ended'", async function() {
            await expect(voting.tallyVotes()).to.be.revertedWith("Current status is not voting session ended");
        });

        it("setVote(1) should change voter's param votedProposalId to 1", async function() {
            await voting.setVote(1);
            const voter = await voting.getVoter(owner.address);
            expect(voter.hasVoted).to.be.true;
            expect(voter.votedProposalId).to.equal(1n);
        });

        it("setVote(2) should change voter's param votedProposalId to 2", async function() {
            await voting.setVote(2);
            const voter = await voting.getVoter(owner.address);
            expect(voter.hasVoted).to.be.true;
            expect(voter.votedProposalId).to.equal(2n);
        });

        it("setVote() should increment the proposal's voteCount in proposalsArray", async function() {
            const beforeVoteProposal = await voting.getOneProposal(1);
            await voting.setVote(1);
            const afterVoteProposal = await voting.getOneProposal(1);
            expect(afterVoteProposal.voteCount).to.equal(beforeVoteProposal.voteCount + 1n);
        });

        it("setVote() should emit Voted event", async function() {
            await expect(voting.setVote(1)).to.emit(voting, "Voted").withArgs(owner.address, 1);
        });

        it("You shouldn't be able to vote multiple times", async function() {
            await voting.setVote(1);
            await expect(voting.setVote(1)).to.be.revertedWith("You have already voted");
        });

        it("You shouldn't be able to vote to an inexistant proposal", async function() {
            await expect(voting.setVote(3)).to.be.revertedWith("Proposal not found");
        });

        it("endVotingSession should emit WorkflowStatusChange event", async function() {
            expect(await voting.endVotingSession()).to.emit(voting, "WorkflowStatusChange").withArgs(3, 4);
        });
    });

    describe("Voting Session Ended", function () {
        beforeEach(async () => {
            await voting.startProposalsRegistering();
            await voting.addProposal("Proposal 1");
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            await voting.setVote(1);
            await voting.endVotingSession();
        });

        it("Starting Voting Session should change workflowStatus to 4", async function() {
            expect(await voting.workflowStatus()).to.equal(4n);
        });

        it("startVotingSession should revertWith 'Registering proposals phase is not finished'", async function() {
            await expect(voting.startVotingSession()).to.revertedWith("Registering proposals phase is not finished");
        });

        it("addVoter() should revert with 'Voters registration is not open yet'", async function() {
            const [, addr1] = await ethers.getSigners();
            await expect(voting.addVoter(addr1.address)).to.be.revertedWith("Voters registration is not open yet");
        });

        it("addProposal() should revert with 'Proposals are not allowed yet'", async function() {
            await expect(voting.addProposal("My Proposal")).to.be.revertedWith("Proposals are not allowed yet");
        });

        it("setVote() should revert with 'Voting session havent started yet'", async function() {
            await expect(voting.setVote(1)).to.be.revertedWith("Voting session havent started yet");
        });

        it("tallyVotes() should assign the winningProposalID", async function() {
            await voting.tallyVotes();
            expect(await voting.winningProposalID()).to.be.equal(1n);
        });

        it("tallyVotes() should change workflowStatus to 5", async function() {
            await voting.tallyVotes();
            expect(await voting.workflowStatus()).to.equal(5n);
        });

        it("tallyVotes() should emit the WorkflowStatusChange event", async function() {
            expect(await voting.tallyVotes()).to.emit(voting, "WorkflowStatusChange").withArgs(4, 5);
        });
    });
});
