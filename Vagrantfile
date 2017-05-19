# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    config.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=700,fmode=600"]
  else
    config.vm.synced_folder ".", "/vagrant"
  end
 
  
  config.vm.define "nfs-server" do |d|
    d.vm.box = "ubuntu/trusty64"
    d.vm.hostname = "nfs-server"
    d.vm.network "private_network", ip: "10.100.192.100"
    d.vm.provision :shell, path: "install-docker.sh"
    d.vm.provision :shell, path: "install-nfs.sh"
    d.vm.provision :shell, path: "setup-monitoring.sh"
    d.vm.provider "virtualbox" do |v|
      v.memory = 2048
	  v.cpus = 2
    end
  end
  
  config.vm.define "swarm-manager-1" do |d|
    d.vm.box = "ubuntu/trusty64"
    d.vm.hostname = "swarm-manager-1"
    d.vm.network "private_network", ip: "10.100.192.200"
    d.vm.provision :shell, path: "install-docker.sh"
	d.vm.provision :shell, path: "enable-convoy.sh"
	d.vm.provision :shell, inline: "sudo docker swarm init --advertise-addr 10.100.192.200"
    d.vm.provision :shell, inline: "docker swarm join-token -q worker >/vagrant/worker-token"
	d.vm.provision :shell, inline: "docker swarm join-token -q manager >/vagrant/manager-token"
    d.vm.provision :shell, path: "install-zabbix-agent.sh"
	d.vm.provider "virtualbox" do |v|
      v.memory = 1024
	  v.cpus = 2
    end
  end
  
  
  config.vm.define "swarm-manager-2" do |d|
    d.vm.box = "ubuntu/trusty64"
    d.vm.hostname = "swarm-manager-2"
    d.vm.network "private_network", ip: "10.100.192.210"
    d.vm.provision :shell, path: "install-docker.sh"
	d.vm.provision :shell, path: "enable-convoy.sh"
    d.vm.provision :shell, inline: "docker swarm join --token $(cat /vagrant/manager-token) --advertise-addr 10.100.192.210 10.100.192.200:2377"
    d.vm.provision :shell, path: "install-zabbix-agent.sh"
    d.vm.provider "virtualbox" do |v|
      v.memory = 1024
	  v.cpus = 2
    end
  end
  
  (1..3).each do |i|
    config.vm.define "swarm-worker-#{i}" do |d|
      d.vm.box = "ubuntu/trusty64"
      d.vm.hostname = "swarm-worker-#{i}"
      d.vm.network "private_network", ip: "10.100.192.20#{i}"
      d.vm.provision :shell, path: "install-docker.sh"
	  d.vm.provision :shell, path: "enable-convoy.sh"
      d.vm.provision :shell, inline: "docker swarm join --token $(cat /vagrant/worker-token) --advertise-addr 10.100.192.20#{i} 10.100.192.200:2377"
      d.vm.provision :shell, path: "install-zabbix-agent.sh"
      d.vm.provider "virtualbox" do |v|
        v.memory = 4096
		v.cpus = 2
      end
    end
  end
  
end