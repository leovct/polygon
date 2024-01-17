# Eth-tx-proof

```bash
$ git clone git@github.com:0xPolygonZero/eth-tx-proof.git \
    && cd eth-tx-proof \
    && CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-unknown-linux-gnu-gcc cargo build --target=x86_64-unknown-linux-gnu \
    && tar -cjf ../prover.tar.bz2 ./target/x86_64-unknown-linux-gnu/debug/leader
```
