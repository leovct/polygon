# 🐳 Setup for polygon-devnets docker PoS

## Table of contents

- [Introduction](#introduction)
- [Setup](#setup)
- [Handy commands](#handy-commands)

## Introduction

In order to build and push new images for the polygon-devnets PoS docker setup, you need an Ubuntu distribution. That's not very convenient since I'm working on macOS. Here are some commands to set up an Ubuntu VM ready for building these images.

The code for building the images and running the setup is located [here](https://github.com/maticnetwork/polygon-devnets/tree/main/docker/pos).

## Setup

### Docker setup

1. Start an Ubuntu 22.04 VM. Make sure to have at least 16GB of memory and 100GB of storage.

2. Connect to the VM

3. Install dependencies

Note: don't forget to [add the public key to your Github account](https://github.com/settings/ssh/new).

You can use this on AWs to enable auto restart when installing packages: `echo -e "\n>> Enabling auto restarting services when upgrading packages.." && sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf`.

```sh
echo -e "\n>> Setting up to build docker pos setup images.." \
  && echo -e "\n>> Setting handy aliases..." \
  && alias docker='sudo docker' \
  && alias make='sudo make' \
  && echo -e "\n>> Installing packages.." \
  && sudo apt-get update \
  && sudo apt-get install -y make jq shellcheck python3-pip unzip \
  && sudo snap install yq \
  && pip install yq \
  && sudo pip install tomlq \
  && echo -e "\n>> Installing docker..." \
  && sudo apt-get install ca-certificates curl gnupg -y \
  && sudo install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && sudo apt-get update \
  && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y \
  && sudo usermod -aG docker $USER \
  && docker run hello-world \
  && echo -e "\n>> Installing go..." \
  && sudo snap install go --classic \
  && go version \
  && echo -e "\n>> Compiling polycli..." \
  && pushd /tmp \
  && git clone https://github.com/maticnetwork/polygon-cli.git \
  && pushd polygon-cli \
  && make build \
  && sudo cp ./out/polycli /usr/bin/ \
  && polycli version \
  && popd \
  && popd \
  && echo -e "\n>> Generating SSH key..." \
  && sudo ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519 -N "" \
  && sudo cat ~/.ssh/id_ed25519.pub
```

On GCP, it can be a bit tedious to clone a private repository. Follow those steps.

```bash
$ eval "$(ssh-agent -s)"
Agent pid 18416
$ ssh-add -l
The agent has no identities.
$ sudo chmod 0644 .ssh/id_ed25519 && ssh-add ~/.ssh/id_ed25519
Identity added: /home/leovct/.ssh/id_ed25519 (your_email@example.com)
```

5. Build the images and start the setup

Note:

- This will ask for user confirmation.
- To build images with Antithesis automation, use `make all` and to start them in containers, use `echo "EXECUTION_FLAGS=--antithesis --race" > .env`.
- For a faster build, run `make all DEV=true` to produce only the `bor-vanilla` and `heimdall-vanilla` binaries, excluding those with `antithesis` and `race` flags. If you prefer this lightweight build, remember to set `EXECUTION_FLAGS=` (no this is not a typo!) in your `.env` file.
- To build the image for Kubernetes, run `make all K8S_ENV=true K8S_NS=<your-namespace>`.

```sh
echo -e "\n>> Building docker images..." \
  && git clone git@github.com:maticnetwork/polygon-devnets.git \
  && cd polygon-devnets/docker/pos \
  && git checkout your-branch \
  && make all DEV=true \
  && docker compose up
```

### Kubernetes setup

6. Install tools to deploy a Kubernetes cluster (optional).

```bash
echo -e "\n>> Installing kubectl..." \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
  && kubectl version --client \
  && echo -e "\n>> Installing kind..." \
  && go install sigs.k8s.io/kind@v0.21.0 \
  && sudo mv $HOME/go/bin/kind /usr/local/bin/kind \
  && kind --version \
  && echo -e "\n>> Creating a local k8s cluster..." \
  && kind create cluster \
  && kind get clusters \
  && kubectl get nodes
```

7. Once docker images have been successfully built (see step 5), you can load them into the k8s cluster (optional).

```bash
kind load docker-image ganache:latest heimdall:latest bor:latest workload:latest status:latest
```

8. Deploy the PoS k8s devnet.

Note: Make sure to update the `namespace` value in both `kustomization.yaml` and `namespace.yaml`.

```bash
kubectl apply -k ./k8s \
  && kubectl get statefulsets -n test \
  && kubectl get deployments -n test \
  && kubectl get pods -n test \
  && kubectl get services -n test
```

## Handy commands

```sh
## Docker commands
alias docker='sudo docker'
docker logs bor_3 -f -n 10
docker exec -it workload /bin/bash
docker ps -a | grep -e 'ganache\|workload\|heimdall\|bor\|config\|status' | awk '{print $1}' | xargs -I xxx docker rm xxx

## Kubernets commands
kubectl describe pods -n test
kubectl logs -n test -f rootchain-5ccc58d466-8m29p
kubectl exec -n test -it rootchain-5ccc58d466-8m29p -- /bin/bash
```
