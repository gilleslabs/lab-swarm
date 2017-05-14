#!/bin/sh


#### Tempoary weird stuff ####

sudo ufw disable

#### Enabling Convoy storage driver plugin migth not be needed to be checked
wget https://github.com/rancher/convoy/releases/download/v0.5.0/convoy.tar.gz
tar xvf convoy.tar.gz
sudo cp convoy/convoy convoy/convoy-pdata_tools /usr/local/bin/

sudo mkdir -p /etc/docker/plugins/
sudo bash -c 'echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec'

sudo apt-get update -y
sudo apt-get install nfs-kernel-server -y
sudo mkdir /convoy-share
sudo echo /convoy-share *\(rw,sync,no_root_squash\) > /etc/exports

sudo mkdir /nfs-share
sudo echo /nfs-share *\(rw,sync,no_root_squash\) >> /etc/exports
sudo service nfs-kernel-server start
sudo exportfs -u


