async function main() {
    
    const baseball = await hre.ethers.getContractFactory("FantasyBaseball");
    const fantasyBaseball = await baseball.deploy('baseball');
    console.log('Deploying contract...');
    await fantasyBaseball.deployed();

    console.log("Contract deployed to:", fantasyBaseball.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });