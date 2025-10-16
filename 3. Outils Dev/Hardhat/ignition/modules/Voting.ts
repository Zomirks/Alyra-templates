import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("VotingModule", (m) => {
  const voting = m.contract("Voting", ["0x71be63f3384f5fb98995898a86b02fb2426c5788"]);

  return { voting };
});
