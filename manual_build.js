const solc = require('solc');
const fs = require('fs');
Web3 = require('web3');
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));

code = fs.readFileSync('lotto.sol').toString();
compiledCode = solc.compile(code);

Contract = web3.eth.contract(JSON.parse(compiledCode.contracts[':VirtLotto'].interface));
console.log(Contract);
byteCode = compiledCode.contracts[':VirtLotto'].bytecode;

// hexString = bytesToHex(byteCode);
// console.log(hexString);
// byteArray = hexToBytes(hexString);
// // console.log(byteArray);

deployedContract = Contract.new(1,
{
    data: byteCode, 
    from: web3.eth.accounts[0],
    gas: 2000000
});
// setTimeout(function(){ console.log("wait 3 seconds for deploy"); }, 3000);

contractInstance = Contract.at(deployedContract.address);
console.log(contractInstance.address);
