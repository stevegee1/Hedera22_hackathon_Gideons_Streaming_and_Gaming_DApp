require("dotenv").config();
const {
    AccountId,
    PrivateKey,
    Client,
    FileCreateTransaction,
    FileAppendTransaction,
    FileContentsQuery,
    Hbar
} = require("@hashgraph/sdk");
const fs = require("fs");
const splitFile = require('split-file');

// Configure accounts and client
const operatorId = AccountId.fromString(process.env.OPERATOR_ID);
const operatorKey = PrivateKey.fromString(process.env.OPERATOR_PVKEY);

const client = Client.forTestnet().setOperator(operatorId, operatorKey);

async function main() {
    // Import the compiled contract bytecode
    try {

        const smartContractBytecodeFilename = "RapBattleContract_sol_Ballotvote.bin";
        const contractBytecode = fs.readFileSync(
            smartContractBytecodeFilename
        );
        const splittedContractByteCode = await splitFile.splitFileBySize(__dirname + `/${smartContractBytecodeFilename}`, 1000);
        let bytecodeFileId;
        for (let i = 0; i < splittedContractByteCode.length; i++) {
            const splitedContractBytecode = fs.readFileSync(
                splittedContractByteCode[i]
            );
            let nodesIds;
            if (i == 0) {
                const fileCreateTx = new FileCreateTransaction()
                    .setContents(splitedContractBytecode)
                    .setKeys([operatorKey])
                    .setMaxTransactionFee(new Hbar(0.75))
                    .freezeWith(client);
                nodesIds = fileCreateTx._nodeAccountIds;
                console.log("nodesIds");
                console.log(nodesIds);
                const fileCreateSign = await fileCreateTx.sign(operatorKey);
                const fileCreateSubmit = await fileCreateSign.execute(client);
                const fileCreateRx = await fileCreateSubmit.getReceipt(client);
                bytecodeFileId = fileCreateRx.fileId;
            }
            else {
                const receipt = await (
                    await new FileAppendTransaction()
                        .setFileId(bytecodeFileId)
                        .setContents(splitedContractBytecode)
                        .setMaxTransactionFee(new Hbar(5))
                        .execute(client)
                ).getReceipt(client);
            }
        }

        const contents = await new FileContentsQuery()
            .setFileId(bytecodeFileId)
            .execute(client);

        console.log("bytecodeFileId");
        console.log(bytecodeFileId);
        console.log("bytecodeFileId");
        console.log(bytecodeFileId.toString());
        // console.log("contents");
        // console.log(contents.toString());
        // console.log("contractBytecode");
        // console.log(contractBytecode.toString());
        // console.log("contents == contractBytecode");
        // console.log(contents == contractBytecode);
        // console.log(`- The bytecode file ID is: ${bytecodeFileId} \n`);
    }
    catch (err) {
        console.log("err");
        console.log(err);
    }
}
main();
