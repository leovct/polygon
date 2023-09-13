#!/bin/bash

rpc_url=http://127.0.0.1:8545
eth_address=0x85dA99c8a7C2C95964c8EfD687E95E632Fc533D6
eth_private_key=0x42b6e34dc21598a807dc19d7784c71b2a7a01f6480dc6f58258f78e539f1a1fa

storage_contract=out/Storage.sol/Storage.json
loadtest_contract=testdata/LoadTester.bin
erc20_contract=testdata/ERC20.bin
erc721_contract=testdata/ERC721.bin

verbosity=701

function deploy_contract() {
	contract_name_lower=$1
	contract_name_upper=$(echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

	echo -e "\n🚀 Deploying $contract_name_upper contract..."
	cast send \
		--from $eth_address \
		--private-key $eth_private_key \
		--rpc-url $rpc_url \
		--json \
		--create \
		"$(jq -r '.bytecode.object' out/$contract_name_upper.sol/$contract_name_upper.json)" | \
		jq '.' | tee out/$contract_name_lower.json
	echo
}

function main() {
	echo "🏗️  Building contracts..."
	forge build

	deploy_contract "snowball"
	deploy_contract "storage"
	deploy_contract "loadtester"
	deploy_contract "erc20"
	deploy_contract "erc721"

	echo -e "\n🪙 Minting ERC20 tokens..."
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json \
	"$(jq -r '.contractAddress' out/erc20.json)" \
	'function mint(uint256 amount) returns()' \
	100000000000000000000000000000 | jq '.' | tee out/erc20.mint.json

	cast call --from $eth_address --rpc-url $rpc_url \
	"$(jq -r '.contractAddress' out/erc20.json)" \
	'function balanceOf(address ) view returns(uint256)' \
	$eth_address

	echo -e "\n➡️  Sending transactions between accounts..."
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 1 --concurrency 1 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 1 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 2 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 4 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 8 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 16 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 32 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 2 --concurrency 64 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 4 --concurrency 64 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 8 --concurrency 64 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 16 --concurrency 64 $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode t --rate-limit 1000 --requests 32 --concurrency 64 $rpc_url

	echo -e "\nStoring random bytes..."
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 1 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 2 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 4 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 8 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 16 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 32 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 64 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 128 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 256 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 512 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 1024 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 2048 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 4096 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 8192 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 16384 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out/loadtest.json)" $rpc_url

	echo -e "\n➡️ Transfering ERC20 between accounts..."
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 1 --concurrency 1 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 2 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 4 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 8 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 16 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 32 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 64 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 4 --concurrency 64 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 8 --concurrency 64 --erc20-address "$(jq -r '.contractAddress' out/erc20.json)" $rpc_url

	echo -e "\nMinting ERC721 tokens..."
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 1 --concurrency 1 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 2 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 4 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 8 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 16 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 32 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 64 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 4 --concurrency 64 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url
	polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 8 --concurrency 64 --erc721-address "$(jq -r '.contractAddress' out/erc721.json)" $rpc_url

	echo -e "\n🚀 Deploying huge contracts..."
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.32.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.64.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.128.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.256.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.512.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.1024.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.2048.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.4096.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.8192.bin)" | jq '.'
	cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url --json --create "$(cat testdata/huge-contract.16384.bin)" | jq '.'

	echo -e "\n❄️ Calling random opcodes using the Snowball contract..."
	seed=65519
	loops=2
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function test(uint64 _seed, uint32 _loops, uint8 _mode) payable returns(bytes32)' \
		$seed $loops 0

	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function test(uint64 _seed, uint32 _loops, uint8 _mode) payable returns(bytes32)' \
		$seed $loops 1

	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function test(uint64 _seed, uint32 _loops, uint8 _mode) payable returns(bytes32)' \
		$seed $loops 2

	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function test(uint64 _seed, uint32 _loops, uint8 _mode) payable returns(bytes32)' \
		$seed $loops 3

	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function test(uint64 _seed, uint32 _loops, uint8 _mode) payable returns(bytes32)' \
		$seed $loops 4

	echo -e "\n💻 Computing prime numbers..."
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		4
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		8
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		16
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		32
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		64
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		128
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		256
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		512
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		1024
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		2048
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		4096
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		8192
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/snowball.json)" --json \
		'function calcPrimes(uint256 ) view returns(uint256)' \
		16384

	echo -e "\nStoring any type of value..."
	cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out/storage.json)" --json \
		'function store() public'
}

trap "echo The script is terminated; exit" SIGINT

main
