//import { ethers } from "hardhat";
import hre from "hardhat";

async function main() {

    const implementation = await hre.ethers.deployContract("HelloWorld");
    await implementation.waitForDeployment();
    const implementationAddress = await implementation.getAddress();
    console.log(`ImplementationAddress deployed at ${implementationAddress}`);    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});