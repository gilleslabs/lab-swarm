!#/bin/sh
docker stack deploy -c /vagrant/demo/traefik/docker-stack.yml traefik
sleep 20
docker stack deploy -c /vagrant/demo/grafana/docker-stack.yml grafana
sleep 180
docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'