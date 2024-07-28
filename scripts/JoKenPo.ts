import { ethers } from "hardhat";

async function main() {
  const joKenPo = await ethers.deployContract("JoKenPo");
  await joKenPo.waitForDeployment();
  const address = joKenPo.getAddress();
  console.log(`Contract deployed at ${address}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });