
import { network } from "hardhat";

const { ethers } = await network.connect({
    network: "localhost",
});

async function main(): Promise<void> {
    const [num1,num2,num3] = await ethers.getSigners();
    console.log('Connection en cours...');
    const Voting = await ethers.getContractAt("Voting","0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e" );
    const tx1 = await Voting.addWhitelist(num2.address);
    await tx1.wait();
    const tx2 = await Voting.startProposalRegistration();
    await tx2.wait();

    const tx3 = await Voting.addProposal("Proposal 1");
    await tx3.wait();
    const tx4 = await Voting.connect(num2).addProposal("Proposal 2");
    await tx4.wait();


    console.log(`fin du script`)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
