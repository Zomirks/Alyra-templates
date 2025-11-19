import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DeFiProject", (m) => {
    const dai = m.contract("Dai");
    const defiProject = m.contract("DeFiProject", [dai]);

    m.call(dai, "faucet", [defiProject, 100]);

    // Récupération du deuxième compte (accounts[1])
    const account1 = m.getAccount(1);

    // Appel de la fonction foo pour transférer 100 DAI à account1
    m.call(defiProject, "foo", [account1, 100]);

    return { dai, defiProject };
});
