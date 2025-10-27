import { network } from "hardhat";

const { ethers } = await network.connect({
    network: "sepolia",
});
console.log("Sending transaction using the Sepolia chain type");

const [sender] = await ethers.getSigners();

async function main(): Promise<void> {
    const age = await ethers.provider.getStorage("0x96884AD36c89DAc00a4dd63060D238C723a0ab3B", 0)
    console.log(`${age}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});