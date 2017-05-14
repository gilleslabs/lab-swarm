#!/bin/sh

######################################################################################################
#                                                                                                    #
#      Setup of $docker variable which will be used for docker VM Shell inline provisioning          #
#                                                                                                    #
######################################################################################################


echo "Build start at    :" > /tmp/build
date >> /tmp/build 

	################     Installing Docker            ###################

sudo apt-get update -y
sudo apt-get purge lxc-docker 

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

sudo apt-get install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update -y
sudo apt-get install docker-ce -y

sudo service docker start
sudo groupadd docker
sudo usermod -aG docker vagrant

################     Installing Docker-Compose            ###################

sudo apt-get -y install python-pip
sudo pip install docker-compose

	################     Updating host and ufw                ###################
	

sudo ufw --force enable

sudo sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|g' /etc/default/ufw
sudo ufw --force reload 
sudo ufw allow 22/tcp
sudo ufw allow 2375/tcp
sudo ufw allow 2376/tcp
sudo ufw allow 2377/tcp
sudo ufw allow 7946/udp
sudo ufw allow 7946/tcp
sudo ufw allow 4789/udp
###### Catching IP address of eth1
ip=$(ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

#### Make docker listening on unix socket and eth1
sudo echo DOCKER_OPTS=\"-D --tls=false -H unix:///var/run/docker.sock -H tcp://$ip:2375\" >> /etc/default/docker
sudo service docker restart

echo "Build completed at      :" >> /tmp/build
date >> /tmp/build
cat /tmp/build
echo
