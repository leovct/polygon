# 🐳 Setup for matic-cli docker PoS

## Table of contents

- [Introduction](#introduction)
- [Setup](#setup)

## Introduction

This setup is similar to the polygon-devnets PoS docker setup but instead, it relies on [matic-cli](https://github.com/maticnetwork/matic-cli#matic-cli) scripts. It is used by the PoS team to check if everything works well.

## Setup

The setup takes some time to run, around 10/20 minutes.

```bash
$ echo "Installing dependencies for matic-cli..." sudo apt-get update --yes \
  && sudo apt-get install --yes build-essential rabbitmq-server ca-certificates curl gnupg npm python2 \
  && echo "Installing go 18..." \
  && wget https://raw.githubusercontent.com/maticnetwork/node-ansible/master/go-install.sh \
  && bash go-install.sh --remove \
  && bash go-install.sh \
  && echo "Installing node 16..." \
  && curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
  && source /home/ubuntu/.bashrc \
  && nvm install 16.20.2 \
  && echo "Setting up alias for python2" \
  && alias python="/usr/bin/python2" \
  && echo "Installing ganache" \
  && npm install --global ganache \
  && echo "Installing solc..." \
  && sudo snap install solc \
  && echo "Installing docker..." \
  && sudo install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && sudo apt-get update \
  && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y \
  && sudo groupadd docker \
  && sudo usermod -aG docker $USER \
  && docker run hello-world \
  && echo "Installing matic-cli" \
  && cd \
  && git clone https://github.com/maticnetwork/matic-cli.git \
  && cd matic-cli \
  && npm install \
  && echo "Creating devnet config..." \
  && mkdir devnet \
  && cd devnet \
  && ../bin/matic-cli setup devnet --config ../configs/devnet/docker-setup-config.yaml | tee setup.log \
  && echo "Starting devnet..." \
  && bash docker-ganache-start.sh \
  && bash docker-heimdall-start-all.sh \
  && bash docker-bor-setup.sh \
  && bash docker-bor-start-all.sh \
  && bash ganache-deployment-bor.sh \
  && bash ganache-deployment-sync.sh \
  && docker ps
```
