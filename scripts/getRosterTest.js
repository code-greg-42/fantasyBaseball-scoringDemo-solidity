const address = '0x7c5151e1d731133b6F21c0162c27E6241c31d293';

async function main() {
    const contract = await hre.ethers.getContractAt("FantasyBaseball", address);
    const getRoster = await contract.getRoster(0);
    console.log(getRoster);
    const player1 = getRoster[0].toNumber();

    console.log(player1);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });