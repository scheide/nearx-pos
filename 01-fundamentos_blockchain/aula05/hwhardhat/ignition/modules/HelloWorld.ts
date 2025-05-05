// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const HelloWorld = buildModule("HelloWorld", (m) => {
   const contract = m.contract("HelloWorld");

  return { contract };
});

export default HelloWorld;
