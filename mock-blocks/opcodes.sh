#!/bin/bash

contract_name=$1
rpc_url=http://127.0.0.1:8545
eth_address=0x85dA99c8a7C2C95964c8EfD687E95E632Fc533D6
eth_private_key=0x42b6e34dc21598a807dc19d7784c71b2a7a01f6480dc6f58258f78e539f1a1fa

function deploy_contract() {
	contract_name_lower=$1
	contract_name_upper=$(echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

	echo "🚀 Deploying $contract_name_upper..."
	cast send \
		--from $eth_address \
		--private-key $eth_private_key \
		--rpc-url $rpc_url \
		-j \
		--create \
		"$(jq -r '.bytecode.object' out/$contract_name_upper.sol/$contract_name_upper.json)" | \
		jq '.' | tee out/$contract_name_lower_deploy.json
	echo
}

function main() {
  echo "🏗️  Building contracts..."
	forge build

  echo
	deploy_contract "snowball"
  deploy_contract "storage"

  echo -e "\n🪄 Executing a few transactions..."
  cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" -j \
		'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
		1 1 65519 | jq > out/snowball_tx.json
  cast rpc debug_traceTransaction "$(jq -r '.transactionHash' out/snowball_tx.json)" {} | \
    jq -r '.structLogs[].op' | sort | uniq  > out/snowball-opcodes.txt

  cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/storage.json)" -j \
		'function store() public' > out/storage_tx.json
  cast rpc debug_traceTransaction "$(jq -r '.transactionHash' out/storage_tx.json)" {} | \
    jq -r '.structLogs[].op' | sort | uniq  > out/storage-opcodes.txt

  sort -u out/snowball-opcodes.txt out/storage-opcodes.txt > seen-opcodes.txt
  sort opcodes.txt <(sort seen-opcodes.txt opcodes.txt | uniq -d) | uniq -u > missing-opcodes.txt

	echo -e "\n❌ Opcodes not called in this transaction (out of all the EVM opcodes):"
	cat missing-opcodes.txt
}

trap "echo The script is terminated; exit" SIGINT

main
