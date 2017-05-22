#!/bin/sh
sudo echo '{
  "registry-mirrors": ["https://10.100.193.10"]
}' >> /etc/docker/daemon.json
sudo service docker restart