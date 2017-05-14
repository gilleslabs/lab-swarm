#!/bin/sh

docker service create --name swarm_visualizer \
  -p 8000:8080 -e HOST=localhost \
  --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock \
  manomarks/visualizer