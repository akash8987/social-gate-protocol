const hre = require("hardhat");

async function main() {
  const SocialGate = await hre.ethers.getContractFactory("SocialGate");
  const gate = await SocialGate.deploy();

  await gate.waitForDeployment();
  console.log(`SocialGate deployed to: ${await gate.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
