#!/bin/sh
docker run \
 --name=dockbix-agent-xxl \
 --net=host \
 --privileged \
 -v /:/rootfs \
 -v /var/run:/var/run \
 -e "ZA_Server=10.100.192.100"\
 -e "ZA_ServerActive=10.100.192.100" \
 -d monitoringartist/dockbix-agent-xxl-limited:latest
 
