const address = '0x7c5151e1d731133b6F21c0162c27E6241c31d293';

async function main() {
    const contract = await hre.ethers.getContractAt("FantasyBaseball", address);
    const addPlayer = await contract.submitPick('grandersson', 592450);
    console.log(addPlayer);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });