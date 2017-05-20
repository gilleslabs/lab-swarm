#!/bin/sh
sudo apt-get install -y bind9
sudo cp /vagrant/bind/named.conf /etc/bind/named.conf
sudo cp /vagrant/bind/example.com.zone /etc/bind/example.com.zone
sudo service bind9 restart
