#!/bin/sh
sudo cp -R /vagrant/bind /srv/.
docker run -d --restart=always \
-p 53:53 -p 53:53/udp \
-p 10000:10000 \
-v /srv/bind:/etc/bind \
-v /srv/bind/zones:/var/lib/bind \
-v /srv/bind/webmin:/etc/webmin \
-e PASS=newpass \
-e NET=172.17.0.0\;192.168.0.0\;10.100.192.0 \
--name bind --hostname bind \
cosmicq/docker-bind
