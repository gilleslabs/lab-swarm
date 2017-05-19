#!/bin/sh
docker run \
    -d \
    --name zabbix-db \
    --env="MARIADB_USER=zabbix" \
    --env="MARIADB_PASS=my_password" \
    monitoringartist/zabbix-db-mariadb

docker run \
   -d \
   --name zabbix-ext-all-templates \
   monitoringartist/zabbix-ext-all-templates:latest
   
docker run \
   -d \
   --name zabbix \
   -p 81:80 \
   -p 10051:10051 \
   -v /etc/localtime:/etc/localtime:ro \
   --volumes-from zabbix-ext-all-templates \
   --link zabbix-db:zabbix.db \
   --env="ZS_DBHost=zabbix.db" \
   --env="ZS_DBUser=zabbix" \
   --env="ZS_DBPassword=my_password" \
   --env="XXL_zapix=true" \
   --env="XXL_grapher=true" \
   --env="XXL_apiuser=Admin" \
   --env="XXL_apipass=zabbix" \
   monitoringartist/zabbix-xxl:latest
   
docker run -d -v /var/lib/grafana --name grafana-xxl-storage busybox:latest

docker run \
  -d \
  -p 3000:3000 \
  --name grafana-xxl \
  --volumes-from grafana-xxl-storage \
  monitoringartist/grafana-xxl:latest