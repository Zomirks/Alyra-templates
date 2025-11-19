import { network } from "hardhat";

const { ethers } = await network.connect({
    network: "localhost",
});

async function main() {
    const dai = await ethers.getContractAt("Dai", "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512");
    const defiProject = await ethers.getContractAt("DeFiProject", "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0");
    const [_, account1] = await ethers.getSigners();

    const balance0 = await dai.balanceOf(defiProject.target);
    const balance1 = await dai.balanceOf(account1.address);

    console.log(balance0.toString());
    console.log(balance1.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});