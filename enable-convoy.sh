#!/bin/sh

#### Enabling Convoy storage driver plugin
wget https://github.com/rancher/convoy/releases/download/v0.5.0/convoy.tar.gz
tar xvf convoy.tar.gz
sudo cp convoy/convoy convoy/convoy-pdata_tools /usr/local/bin/
sudo mkdir -p /etc/docker/plugins/
sudo bash -c 'echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec'
sudo service docker restart
sudo mkdir /convoy-nfs
sudo mkdir /shared-nfs

sudo mount -t nfs -o nolock 10.100.192.100:/convoy-share /convoy-nfs
sudo mount -t nfs -o nolock 10.100.192.100:/nfs-share /shared-nfs

sudo cp /vagrant/convoy /etc/init/convoy
sudo ln -s /etc/init/convoy /etc/init.d/convoy
sudo chmod 755 /etc/init.d/convoy
sudo service convoy start

