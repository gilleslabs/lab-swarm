#!/bin/sh
sudo mkdir -p /certs
sudo openssl req -newkey rsa:4096 -nodes -sha256 -keyout /certs/domain.key \
        -x509 -days 3650 -out /certs/domain.crt -subj "/C=FR/L=Cannes/O=lab-swarm/CN=registry.infra.local"
sudo mkdir -p /etc/docker/certs.d/registry.infra.local
sudo cp /certs/domain.crt /etc/docker/certs.d/registry.infra.local:5000/ca.crt
sudo cp /certs/domain.crt /vagrant/demo/registry/certs/ca.crt
sudo mkdir -p /auth
docker run --entrypoint htpasswd registry:2 -Bbn testuser testpassword > /auth/htpasswd
cd /vagrant/demo/registry
sudo docker-compose up -d
