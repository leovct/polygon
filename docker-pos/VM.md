# 🐳 VM Setup Playbook for Docker PoS

## Table of contents

- [Introduction](#introduction)
- [Setup](#setup)
- [Handy commands](#handy-commands)

## Introduction

In order to build and push new images for the Polygon PoS docker setup, you need an Ubuntu distribution. That's not very convenient since I'm working on macOS. Here are some commands to set up an Ubuntu VM ready for building these images.

The code for building the images and running the setup is located [here](https://github.com/maticnetwork/polygon-devnets/tree/dc43ac13f6fefa8fdaa82574df98727c4ff4b429/docker/pos).

## Setup

1. Start an Ubuntu 22.04 VM. Make sure to have at least 16GB of memory and 100GB of storage.

2. Connect to the VM

3. Install dependencies

```sh
echo "Set up to build docker pos setup images" \
  && echo "Set handy aliases" \
  && alias docker='sudo docker' \
  && alias make='sudo make' \
  && echo "Install packages" \
  && sudo apt-get update \
  && sudo apt-get install -y make jq shellcheck python3-pip \
  && sudo snap install yq \
  && pip install yq \
  && echo "Install Docker (https://docs.docker.com/engine/install/ubuntu/)" \
  && sudo apt-get install ca-certificates curl gnupg -y \
  && sudo install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && sudo apt-get update \
  && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y \
  && sudo docker run hello-world \
  && echo "Install polycli (https://github.com/maticnetwork/polygon-cli)" \
  && cd /tmp \
  && curl -s -LO https://github.com/maticnetwork/polygon-cli/releases/download/v0.1.28/polycli_0.1.28_linux_amd64.tar.gz \
  && tar -xzf polycli_0.1.28_linux_amd64.tar.gz \
  && sudo mv polycli_0.1.28_linux_amd64/polycli /usr/bin/ \
  && polycli version
```

4. Make sure `tomlq` is installed (most of the time, this is the reason why `init.sh` fails)

```sh
sudo su
pip install tomlq
```

5. Generate an SSH key to clone the `polygon-devnets` private repository. Don't forget to [add it to your Github account](https://github.com/settings/ssh/new).

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" && cat ~/.ssh/id_ed25519.pub
```

6. Build the images and start the setup

```sh
cd \
  && git clone git@github.com:maticnetwork/polygon-devnets.git \
  && cd polygon-devnets/docker/pos \
  && touch private.env \
  && echo "EXECUTION_FLAGS=--antithesis --race" > .env \
  && make all \
  && docker compose up
```

## Handy commands

```sh
alias docker='sudo docker'
docker logs $(docker ps -a | grep -E 'bor_3' | awk '{print $1}') -f -n 10
docker exec -it $(docker ps | grep -E 'config' | awk '{print $1}') /bin/bash
```