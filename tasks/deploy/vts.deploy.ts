import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

import { VTS, VTS__factory } from "../../typechain";

task("deploy:VTS").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const VTSFactory: VTS__factory = <VTS__factory>await ethers.getContractFactory("VTS");
  const VTS: VTS = <VTS>await VTSFactory.deploy();
  await VTS.deployed();
  console.log("TK1 deployed to: ", VTS.address);
});
