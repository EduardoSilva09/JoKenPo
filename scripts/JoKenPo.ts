import { ethers } from "hardhat";

async function main() {
  const implementation = await ethers.deployContract("JoKenPo");
  await implementation.waitForDeployment();
  const implementationAddress = await implementation.getAddress();
  console.log(`Implementation deployed at ${implementationAddress}`);

  const adapter = await ethers.deployContract("JKPAdapter");
  await adapter.waitForDeployment();
  const adapterAddress = await adapter.getAddress();
  console.log(`Adapter deployed at ${adapterAddress}`);

  await adapter.upgrade(implementationAddress);
  console.log('Adapter was upgraded.');
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });