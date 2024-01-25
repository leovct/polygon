# Test a custom Ansible collection

The purpose of this guide is to provide a way to test our [`blockchain.tools`](https://github.com/praetoriansentry/blockchain.tools) Ansible collection.

In order to do that, we will provision a VM (compute instance) on GCP using a very simple playbook that installs roles of our custom Ansible collection.

## Generate the Ansible inventory for GCP

Run this handy script that will fetch GCP compute instances data and format it for Ansible to use as an inventory.

```bash
$ ./setup.sh
Usage: ./setup.sh <project_id> <filter>
For example: ./setup.sh prj-polygonlabs-devtools-dev name:my-super-instance

$ ./setup.sh prj-polygonlabs-devtools-dev name:test-blockchain-tools-collection
Setting up the inventory for GCP...
PROJECT=prj-polygonlabs-devtools-dev
FILTER=name:test-blockchain-tools-collection

New inventory:
...

Done!
```

## Install the Ansible custom collection

```bash
$ ansible-galaxy install -r requirements.yml
Starting galaxy collection install process
[WARNING]: Collection prometheus.prometheus does not support Ansible version 2.15.0
Process install dependency map
Cloning into '/Users/leovct/.ansible/tmp/ansible-local-1094icp2sx81/tmph9wsgpdn/blockchain.toolsfou_sf2l'...
remote: Enumerating objects: 168, done.
remote: Counting objects: 100% (168/168), done.
remote: Compressing objects: 100% (96/96), done.
remote: Total 168 (delta 63), reused 133 (delta 31), pack-reused 0
Receiving objects: 100% (168/168), 27.75 KiB | 6.94 MiB/s, done.
Resolving deltas: 100% (63/63), done.
branch 'feat/grafana' set up to track 'origin/feat/grafana'.
Switched to a new branch 'feat/grafana'
Starting collection install process
Installing 'blockchain.tools:0.1.10' to '/Users/leovct/.ansible/collections/ansible_collections/blockchain/tools'
Created collection for blockchain.tools:0.1.10 at /Users/leovct/.ansible/collections/ansible_collections/blockchain/tools
blockchain.tools:0.1.10 was installed successfully
```

## Run the playbook

```bash
# Make sure to provide the public key to the VMs (e.g. using the UI).
$ ansible-playbook --private-key ~/.ssh/ansible_ed25519 site.yml
...

$ ansible-playbook --private-key ~/.ssh/ansible_ed25519 site.yml
...
```
