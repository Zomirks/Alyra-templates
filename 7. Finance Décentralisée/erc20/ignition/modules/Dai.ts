import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Dai", (m) => {
  const dai = m.contract("Dai");

  return { dai };
});
