#!/bin/sh
docker run -d --dns=10.100.192.100 -p 6080:80 -p 5900:5900 dorowu/ubuntu-desktop-lxde-vnc -d