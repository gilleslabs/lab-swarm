#!/bin/sh
sudo echo 'Acquire::HTTP::Proxy "http://10.100.193.10:3142";' >> /etc/apt/apt.conf.d/01proxy 
sudo echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy