import { network } from "hardhat";

const { ethers } = await network.connect({
    network: "localhost",
});

async function main(): Promise<void> {
    console.log('Connection au contrat en cours...');

    const Counter = await ethers.getContractAt("Counter","0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512" );
    console.log(`Connexion faite à counter déployé à ${Counter.target}`);
    console.log(`Action en cours...`);

    const tx = await Counter.inc();
    await tx.wait();
    const count = await Counter.x();
    
    console.log(`Action effectuée, le nouveau count est de : ${count}`)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});