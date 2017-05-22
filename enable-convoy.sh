#!/bin/sh

#### Enabling Convoy storage driver plugin
wget https://github.com/rancher/convoy/releases/download/v0.5.0/convoy.tar.gz
tar xvf convoy.tar.gz
sudo cp convoy/convoy convoy/convoy-pdata_tools /usr/local/bin/
sudo mkdir -p /etc/docker/plugins/
sudo bash -c 'echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec'
sudo service docker restart

## Dummy workaround to register convoy volume

sudo mkdir /convoy-nfs
sudo mkdir /nfs-share
sudo mkdir /demo

sudo mount -t nfs -o nolock 10.100.193.100:/convoy-nfs /convoy-nfs
sudo mount -t nfs -o nolock 10.100.193.100:/nfs-share /nfs-share
sudo mount -t nfs -o nolock 10.100.193.100:/demo /demo

sudo cp /vagrant/convoy /etc/init/convoy
sudo ln -s /etc/init/convoy /etc/init.d/convoy
sudo chmod 755 /etc/init.d/convoy
sudo service convoy start


sudo echo 10.100.193.100:/convoy-nfs /convoy-nfs nfs auto,nolock > /etc/fstab
sudo echo 10.100.193.100:/nfs-share /nfs-share nfs auto,nolock >> /etc/fstab
sudo echo 10.100.193.100:/demo /demo nfs auto,nolock >> /etc/fstab

## Dummy workaround to register convoy volume
docker volume create -d convoy test
docker volume rm test