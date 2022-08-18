const {ethers} = require('ethers');
const address = '0x7c5151e1d731133b6F21c0162c27E6241c31d293';

async function main() {
    let pw = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('password'));
    console.log(pw);
    const contract = await hre.ethers.getContractAt("FantasyBaseball", address);
    const addTeam = await contract.join('baseball', 'the most og team', 'grandersson', '0x67a634C89d77b6e5FcC769A75B246Ebd5BF95d58', pw, []);
    console.log(addTeam);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });