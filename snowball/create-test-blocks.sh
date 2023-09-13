#!/bin/bash

#rpc_url=http://127.0.0.1:10002
rpc_url=http://35.190.116.103
eth_address=0x85dA99c8a7C2C95964c8EfD687E95E632Fc533D6
eth_private_key=0x42b6e34dc21598a807dc19d7784c71b2a7a01f6480dc6f58258f78e539f1a1fa

snowball_contract=out/Snowball.sol/Snowball.json
storage_contract=out/Storage.sol/Storage.json
loadtest_contract=testdata/LoadTester.bin
erc20_contract=testdata/ERC20.bin
erc721_contract=testdata/ERC721.bin

verbosity=701

function main() {

    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create \
         "$(jq -r '.bytecode.object' $snowball_contract)" | \
        jq '.' | tee out.snowball.json

    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create \
         "$(cat $loadtest_contract)" | \
        jq '.' | tee out.loadtest.json

    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create \
         "$(cat $erc20_contract)" | \
        jq '.' | tee out.erc20.json

    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create \
         "$(cat $erc721_contract)" | \
        jq '.' | tee out.erc721.json

    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j \
         "$(jq -r '.contractAddress' out.erc20.json)" \
         'function mint(uint256 amount) returns()' \
         100000000000000000000000000000 | jq '.' | tee out.erc20.mint.json

    cast call --from $eth_address --rpc-url $rpc_url \
         "$(jq -r '.contractAddress' out.erc20.json)" \
         'function balanceOf(address ) view returns(uint256)' \
         $eth_address



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


    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 1 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 2 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 4 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 8 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 16 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 32 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 64 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 128 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 256 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 512 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 1024 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 2048 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 4096 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 8192 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode s --byte-count 16384 --rate-limit 1000 --requests 1 --concurrency 1 --lt-address "$(jq -r '.contractAddress' out.loadtest.json)" $rpc_url


    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 1 --concurrency 1 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 2 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 4 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 8 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 16 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 32 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 2 --concurrency 64 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 4 --concurrency 64 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 2 --rate-limit 500 --requests 8 --concurrency 64 --erc20-address "$(jq -r '.contractAddress' out.erc20.json)" $rpc_url


    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 1 --concurrency 1 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 2 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 4 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 8 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 16 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 32 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 2 --concurrency 64 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 4 --concurrency 64 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url
    polycli loadtest --legacy --verbosity $verbosity --mode 7 --rate-limit 500 --requests 8 --concurrency 64 --erc721-address "$(jq -r '.contractAddress' out.erc721.json)" $rpc_url


    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.32.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.64.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.128.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.256.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.512.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.1024.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.2048.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.4096.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.8192.bin)" | jq '.'
    cast send --from $eth_address --private-key $eth_private_key --rpc-url $rpc_url -j --create "$(cat testdata/huge-contract.16384.bin)" | jq '.'


    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
         1 1 65519

    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
         2 2 65519

    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
         4 4 65519

    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
         8 8 65519

    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
         16 16 65519

    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function test(uint64 _seed, uint32 loops, uint256 mode) payable returns(bytes32)' \
         32 32 65519


    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         4
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         8
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         16
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         32
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         64
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         128
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         256
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         512
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         1024
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         2048
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         4096
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         8192
    cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.snowball.json)" -j \
         'function calcPrimes(uint256 ) view returns(uint256)' \
         16384

     cast send --private-key $eth_private_key --rpc-url $rpc_url "$(jq -r '.contractAddress' out.storage.json)" -j \
         'function store() public'

}

trap "echo The script is terminated; exit" SIGINT

main
