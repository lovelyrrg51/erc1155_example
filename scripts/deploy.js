// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const typeOneURI = "https://typeOneNFT.io/uri";
  const typeTwoURI = "https://typeTwoNFT.io/uri";
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");
  // await greeter.deployed();
  // console.log("Greeter deployed to:", greeter.address);

  const typeOne = await hre.ethers.getContractFactory("Type1");
  const typeOneInstance = await typeOne.deploy(typeOneURI);
  await typeOneInstance.deployed();

  console.log("Type One Address: ", typeOneInstance.address);

  const typeTwo = await hre.ethers.getContractFactory("Type2");
  const typeTwoInstance = await typeTwo.deploy(typeTwoURI);
  await typeTwoInstance.deployed();

  console.log("Type Two Address: ", typeTwoInstance.address);

  // Set typeOne Address
  await typeTwoInstance.setTypeOneAddress(typeOneInstance.address);
  // Set typeTwo Address
  await typeOneInstance.setTypeTwoToken(typeTwoInstance.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
