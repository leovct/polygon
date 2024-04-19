# zkEVM/CDK Config Diff Tool

A simple tool to compare our current zkEVM/CDK configurations with the default ones and list any missing or unnecessary fields.

## Usage

1. Deploy the CDK stack using [kurtosis-cdk](https://github.com/0xPolygon/kurtosis-cdk).

2. Create folders to hold default and current configuration files.

```bash
mkdir -p default current
```

3. Dump default configurations.

```bash
sh dump_zkevm_config.sh dump default ./default
```

4. Dump current configurations.

```bash
sh dump_zkevm_config.sh dump current ./current
```

5. Compare configurations. You'll find diffs in `./diff`.

```bash
sh dump_zkevm_config.sh compare configs default current
```