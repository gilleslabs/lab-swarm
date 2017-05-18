#!/bin/sh

# Allows to easily spin up a Docker Swarm Mode (1.12+) monitoring solution
# Prometheus (metrics database) http://<host-ip>:9090
# AlertManager (alerts management) http://<host-ip>:9093
# Grafana (visualize metrics) http://<host-ip>:3000
# NodeExporter (host metrics collector)
# cAdvisor (containers metrics collector)
#
# Larry Smith Jr.
# @mrlesmithjr
# http://everythingshouldbevirtual.com

# Turn on verbose execution
set -x

# Define variables
PERSISTENT_DATA_MOUNT="/mnt/docker-persistent-storage"
PRI_DOMAIN_NAME="etsbv.internal"
ALERTMANAGER_DATA_MOUNT_SOURCE="$PERSISTENT_DATA_MOUNT/alertmanager"
ALERTMANAGER_DATA_MOUNT_TARGET="/etc/alertmanager"
ALERTMANAGER_DATA_MOUNT_TYPE="bind"
ALERTMANAGER_IMAGE="prom/alertmanager"
ALERTMANAGER_URL="http://alertmanager.$PRI_DOMAIN_NAME:9093"
BACKEND_NET="monitoring"
CADVISOR_IMAGE="google/cadvisor:v0.24.1"
GRAFANA_ADMIN_PASS="P@55w0rd"
GRAFANA_DATA_MOUNT_SOURCE="$PERSISTENT_DATA_MOUNT/grafana"
GRAFANA_DATA_MOUNT_TARGET="/var/lib/grafana"
GRAFANA_DATA_MOUNT_TYPE="bind"
GRAFANA_EXTRA_ARGS="GF_SECURITY_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASS"
GRAFANA_IMAGE="grafana/grafana"
LABEL_GROUP="monitoring"
NODEEXPORTER_IMAGE="prom/node-exporter"
PROMETHEUS_DATA_MOUNT_SOURCE="$PERSISTENT_DATA_MOUNT/prometheus"
PROMETHEUS_DATA_MOUNT_TYPE="bind"
PROMETHEUS_DATA_MOUNT_TARGET="/prometheus"
PROMETHEUS_IMAGE="prom/prometheus"

# Check/create Backend Network if missing
docker network ls | grep $BACKEND_NET
RC=$?
if [ $RC != 0 ]; then
  docker network create -d overlay $BACKEND_NET
fi

# Check/create Data Mount Targets
if [ ! -d $ALERTMANAGER_DATA_MOUNT_SOURCE ]; then
  mkdir $ALERTMANAGER_DATA_MOUNT_SOURCE
fi
if [ ! -d $GRAFANA_DATA_MOUNT_SOURCE ]; then
  mkdir $GRAFANA_DATA_MOUNT_SOURCE
fi
if [ ! -d $PROMETHEUS_DATA_MOUNT_SOURCE ]; then
  mkdir $PROMETHEUS_DATA_MOUNT_SOURCE
fi

# Check for running cadvisor and spinup if not running
docker service ls | grep cadvisor
RC=$?
if [ $RC != 0 ]; then
  docker service create --name cadvisor \
    --mount type=bind,source=/var/lib/docker/,destination=/var/lib/docker:ro \
    --mount type=bind,source=/var/run,destination=/var/run:rw \
    --mount type=bind,source=/sys,destination=/sys:ro \
    --mount type=bind,source=/,destination=/rootfs:ro \
    --label org.label-schema.group="$LABEL_GROUP" \
    --network $BACKEND_NET \
    --mode global \
    $CADVISOR_IMAGE
fi

# Check for running nodeexporter and spinup if not running
docker service ls | grep nodeexporter
RC=$?
if [ $RC != 0 ]; then
  docker service create --name nodeexporter \
    --label org.label-schema.group="$LABEL_GROUP" \
    --network $BACKEND_NET \
    --mode global \
    $NODEEXPORTER_IMAGE
#       -collector.procfs /host/proc \
#       -collector.sysfs /host/sys \
#       -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)" \
#         --collector.textfile.directory /etc/node-exporter/ \
#         --collectors.enabled="conntrack,diskstats,entropy,filefd,filesystem,loadavg,mdadm,meminfo,netdev,netstat,stat,textfile,time,vmstat,ipvs"
fi

# Check for running alertmanager and spinup if not running
docker service ls | grep alertmanager
RC=$?
if [ $RC != 0 ]; then
  docker service create --name alertmanager \
    --mount type=$ALERTMANAGER_DATA_MOUNT_TYPE,source=$ALERTMANAGER_DATA_MOUNT_SOURCE,target=$ALERTMANAGER_DATA_MOUNT_TARGET \
      --label org.label-schema.group="$LABEL_GROUP" \
      --network $BACKEND_NET \
      --publish 9093:9093 \
      $ALERTMANAGER_IMAGE
fi

# Check for running prometheus and spinup if not running
docker service ls | grep prometheus
RC=$?
if [ $RC != 0 ]; then
  docker service create --name prometheus \
    --mount type=$PROMETHEUS_DATA_MOUNT_TYPE,source=$PROMETHEUS_DATA_MOUNT_SOURCE,target=$PROMETHEUS_DATA_MOUNT_TARGET \
      --label org.label-schema.group="$LABEL_GROUP" \
      --network $BACKEND_NET \
      --publish 9090:9090 \
      $PROMETHEUS_IMAGE \
      -alertmanager.url=$ALERTMANAGER_URL
 fi
 
 # Check for running grafana and spinup if not running
docker service ls | grep grafana
RC=$?
if [ $RC != 0 ]; then
  docker service create --name grafana \
    --mount type=$GRAFANA_DATA_MOUNT_TYPE,source=$GRAFANA_DATA_MOUNT_SOURCE,target=$GRAFANA_DATA_MOUNT_TARGET \
      --label org.label-schema.group="$LABEL_GROUP" \
      --network $BACKEND_NET \
      --publish 3000:3000 \
      -e $GRAFANA_EXTRA_ARGS \
      $GRAFANA_IMAGE
 fi