BOX_NAME = "hashicorp/bionic64"
BOX_RAM_MB = "512"
VM1_HOSTNAME = "server1"
VM1_IP = "192.168.56.101"
VM2_HOSTNAME= "server2"
VM2_IP = "192.168.56.102"

ssh_private_key_path = "./id_rsa"
ssh_public_key_path  = "./id_rsa.pub"
ssh_public_key = File.readlines("#{ssh_public_key_path}").first.strip
repo_path = "https://github.com/rgsx/epam-tasks"
repo_branch = "task2"
repo_file = "test2.txt"

$script = <<-SCRIPT
hostname -s
echo "#{VM1_IP} #{VM1_HOSTNAME}" >> /etc/hosts
echo "#{VM2_IP} #{VM2_HOSTNAME}" >> /etc/hosts
 echo #{ssh_public_key} >> /home/vagrant/.ssh/authorized_keys
 mv /tmp/key /home/vagrant/.ssh/id_rsa
 chown vagrant /home/vagrant/.ssh/id_rsa
 chmod 400 /home/vagrant/.ssh/id_rsa

if [ `hostname -s` = #{VM1_HOSTNAME} ]; then
  apt update && \
  apt install -y git && \
  rm -rf /var/lib/apt/lists/*
  cd ~  && \
  git clone #{repo_path} repo && \
  cd ./repo && \
  git checkout #{repo_branch} && \
  cat #{repo_file}
fi
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "server1" do |server1|
    server1.vm.box = BOX_NAME
    server1.vm.hostname = VM1_HOSTNAME
    server1.ssh.forward_agent = true   
    server1.vm.provision "file", source: "#{ssh_private_key_path}", destination: "/tmp/key"
    server1.vm.provision "shell", inline: $script
    server1.vm.network :private_network, ip: VM1_IP
    server1.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", BOX_RAM_MB]
      v.customize ["modifyvm", :id, "--name", VM1_HOSTNAME]
    end
  end

  config.vm.define "server2" do |server2|
    server2.vm.box = BOX_NAME
    server2.vm.hostname = VM2_HOSTNAME
    server2.ssh.forward_agent = true   
    server2.vm.provision "file", source: "#{ssh_private_key_path}", destination: "/tmp/key"
    server2.vm.provision "shell", inline: $script
    server2.vm.network :private_network, ip: VM2_IP
    server2.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", BOX_RAM_MB]
      v.customize ["modifyvm", :id, "--name", VM2_HOSTNAME]
    end
  end
end
