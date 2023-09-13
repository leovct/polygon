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
		--json \
		--create \
		"$(jq -r '.bytecode.object' out/$contract_name_upper.sol/$contract_name_upper.json)" \
		| jq '.' \
		| tee out/${contract_name_lower}_deploy.json
	echo
}

function call_opcodes() {
	seed=$1
	loops=$2
	mode=$3
	echo -e "\n🪄 Calling random opcodes (seed=$seed,loops=$loops,mode=$mode)..."
  cast send \
		--from $eth_address \
		--private-key $eth_private_key \
		--rpc-url $rpc_url \
		--json \
		"$(jq -r '.contractAddress' out/snowball_deploy.json)" \
		'function test(uint64 _seed, uint32 _loops, uint8 _mode) payable returns(bytes32)' $seed $loops $mode \
		| jq > out/snowball_tx$mode.json
	cat out/snowball_tx$mode.json
	cast rpc debug_traceTransaction "$(jq -r '.transactionHash' out/snowball_tx$mode.json)" {} \
    | jq -r '.structLogs[].op' | sort | uniq > out/snowball_tx${mode}_opcodes.txt
}

function main() {
  echo "🏗️  Building contracts..."
	forge build

	# Contract deployment.
  echo
	deploy_contract "snowball"
  deploy_contract "storage"

  # Executing transactions.
	## Calling random opcodes.
	seed=65519
	loops=1
	call_opcodes $seed $loops 0
	call_opcodes $seed $loops 1
	call_opcodes $seed $loops 2
	call_opcodes $seed $loops 3
	call_opcodes $seed $loops 4

	## Storing values.
	echo -e "\n 🪄 Storing all types of values..."
  cast send \
		--from $eth_address \
		--private-key $eth_private_key \
		--rpc-url $rpc_url "$(jq -r '.contractAddress' out/storage_deploy.json)" -j \
		'function store() public' \
		| jq > out/storage_tx.json
	cat out/storage_tx.json
  cast rpc debug_traceTransaction "$(jq -r '.transactionHash' out/storage_tx.json)" {} \
    | jq -r '.structLogs[].op' | sort | uniq > out/storage_opcodes.txt

	# Displaying missing opcodes.
	echo -e "\n❌ Opcodes not called in this transaction (out of all the EVM opcodes):"
	sort -u \
		out/snowball_tx0_opcodes.txt \
		out/snowball_tx1_opcodes.txt \
		out/snowball_tx2_opcodes.txt \
		out/snowball_tx3_opcodes.txt \
		out/snowball_tx4_opcodes.txt \
		out/storage_opcodes.txt \
		> seen-opcodes.txt
  sort opcodes.txt <(sort seen-opcodes.txt opcodes.txt | uniq -d) | uniq -u > missing-opcodes.txt
	cat missing-opcodes.txt
}

trap "echo The script is terminated; exit" SIGINT

main
