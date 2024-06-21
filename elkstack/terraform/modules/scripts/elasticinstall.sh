#!/bin/bash

# Install Docker
 sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

sudo apt-get update
sudo apt-get upgrade -y

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo docker run hello-world

# Install ElasticSearch/Kibana

if [ $? -eq 0 ]; then
  echo "Docker installed successfully"
  echo "Installing ElasticSearch..."
  sudo mkdir -p /usr/share/elasticsearch
  cd /usr/share/elasticsearch
  sudo wget https://raw.githubusercontent.com/darinfulton/elkstack/master/elkstack/terraform/configs/docker-compose.yml
  sudo wget https://raw.githubusercontent.com/darinfulton/elkstack/master/elkstack/terraform/configs/.env
  sysctl -w vm.max_map_count=262144
  sudo docker compose up -d

else
  echo "Docker installation failed"
  exit 1
fi