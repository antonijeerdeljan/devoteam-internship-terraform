#!/bin/bash

sudo apt-get update

sudo apt-get install -y \
     ca-certificates \
     curl \
     gnupg \
     lsb-release

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

mkdir -p /home/antonijeerdeljan01/devoteam-app

sudo gsutil cp -r gs://devoteam-app/* /home/antonijeerdeljan01/devoteam-app

cd /home/antonijeerdeljan01/devoteam-app/devoteam-internship

sudo docker compose up
