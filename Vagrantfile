TOMCAT_COUNT = 2
TOMCAT_PATH = "https://mirror.datacenter.by/pub/apache.org/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz"

BOX_NAME = "hashicorp/bionic64"
BOX_RAM_MB = "512"

APACHE_HOSTNAME = "apache"
APACHE_IP = "192.168.56.101"
APACHE_PORT = "8080"

TOMCAT_START_IP="192.168.56.102"
TOMCAT_PORT="8009"

Vagrant.configure("2") do |config|
  
  config.vm.provider :virtualbox do |vb|
    vb.memory = 512
    vb.cpus = 1
  end  

  (1..TOMCAT_COUNT).each do |i|
    config.vm.define "tomcat#{i}" do |node|
      node.vm.hostname = "tomcat#{i}"
      node.vm.box = BOX_NAME
      node.vm.hostname = "tomcat#{i}"
      node.vm.network :private_network, ip: "192.168.56.#{101+i}"
      node.vm.provision "file", source: "tomcat/server.xml", destination: "/tmp/server.xml"
      node.vm.provision "file", source: "tomcat/tomcat.sh", destination: "/tmp/tomcat.sh"
      node.vm.provision "file", source: "tomcat/tomcat.service", destination: "/tmp/tomcat.service"
      node.vm.provision "shell", inline: "chmod a+x /tmp/tomcat.sh && env TOMCAT_COUNT=#{i} TOMCAT_PATH=#{TOMCAT_PATH}  /tmp/tomcat.sh"
    end
  end

  config.vm.define "apache" do |apache|
    apache.vm.box = BOX_NAME
    apache.vm.hostname = APACHE_HOSTNAME
    apache.vm.network :private_network, ip: APACHE_IP
    apache.vm.network "forwarded_port", guest: 80, host: "#{APACHE_PORT}"
    apache.vm.provision "file", source: "apache/000-default.conf", destination: "/tmp/000-default.conf"
    apache.vm.provision "file", source: "apache/apache.sh", destination: "/tmp/apache.sh"
    apache.vm.provision "shell", inline: "chmod a+x /tmp/apache.sh && env TOMCAT_COUNT=#{TOMCAT_COUNT} TOMCAT_START_IP=#{TOMCAT_START_IP} TOMCAT_PORT=#{TOMCAT_PORT} /bin/bash  /tmp/apache.sh"
  end

end
