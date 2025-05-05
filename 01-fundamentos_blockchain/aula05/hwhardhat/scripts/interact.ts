//import { ethers } from "hardhat";
import hre from "hardhat";

import ABI from "./abi.json";
import { AbiType } from "./abiType";

async function main() {

    const implementation = await hre.ethers.deployContract("HelloWorld");
    await implementation.waitForDeployment();
    const implementationAddress = await implementation.getAddress();
    console.log(`ImplementationAddress deployed at `+`${implementationAddress}`.toLowerCase());  
    
    //O signer vem das configurações da network em hardhat.config.ts
    const signer = await hre.ethers.provider.getSigner()
 
    const contract = new hre.ethers.Contract(`${implementationAddress}`, ABI, signer);

    let message = await contract.message();
    
    console.log("First Message: ", message);
    
    const tx = await contract.setMessage("new message");

    message = await contract.message();
    
    //console.log("Interaction: ", tx.transactionHash);
    console.log("Interaction: ", tx.hash);

    console.log("TestMessage: ", message);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
