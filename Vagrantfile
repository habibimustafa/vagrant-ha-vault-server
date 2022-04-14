# -*- mode: ruby -*-
# vi: set ft=ruby :

CONSUL_PREFIX = "consul"
CONSUL_CLUSTER_IPS = ["192.168.58.11","192.168.58.12","192.168.58.13"]

VAULT_PREFIX = "vault"
VAULT_SERVER_IPS = ["192.168.58.101", "192.168.58.102"]

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

  cluster_ips = CONSUL_CLUSTER_IPS
  cluster_ips.each_with_index do |node_ip, index|
    box_hostname = "#{CONSUL_PREFIX}-s#{index+1}"

    config.vm.define box_hostname do |db|
      db.vm.hostname = box_hostname
      db.vm.network "private_network", ip: node_ip

      db.vm.provider "virtualbox" do |vb|
        vb.name = box_hostname
      end

      db.vm.provision "shell", run: "once", inline: <<-SHELL
        useradd --no-create-home --shell /bin/false consul
        mkdir -p /var/consul/data
        chown -R consul:consul /var/consul/
        mkdir /etc/consul.d
        cp /vagrant/consul-server.json /etc/consul.d/consul.json
        cp /vagrant/consul.service /etc/systemd/system/
        cp /vagrant/consul /usr/bin/
      SHELL

      retry_joins = cluster_ips.map { |ip| "\"#{ip}\"" }.join(', ')
      replace_node_name = "sed -i 's/$NODE_NAME/#{box_hostname}/g' /etc/consul.d/consul.json"
      replace_advertise_addr = "sed -i 's/$ADVERTISE_ADDR/#{node_ip}/' /etc/consul.d/consul.json"
      replace_all_retry_joins = "sed -i 's/\"$RETRY_JOINS\"/[#{retry_joins}]/' /etc/consul.d/consul.json"

      db.vm.provision :shell, run: 'once', inline: replace_node_name
      db.vm.provision :shell, run: 'once', inline: replace_advertise_addr
      db.vm.provision :shell, run: 'once', inline: replace_all_retry_joins

      db.vm.provision "shell", run: "once", inline: <<-SHELL
        systemctl daemon-reload
        systemctl enable consul.service
        systemctl start consul.service
        systemctl status consul.service
      SHELL
    end
  end

  vault_ips = VAULT_SERVER_IPS
  vault_ips.each_with_index do |node_ip, index|
    box_hostname = "#{VAULT_PREFIX}-c#{index+1}"
    config.vm.define box_hostname do |db|
      db.vm.hostname = box_hostname
      db.vm.network "private_network", ip: node_ip

      db.vm.provider "virtualbox" do |vb|
        vb.name = box_hostname
      end

      db.vm.provision "shell", run: "once", inline: <<-SHELL
        useradd --no-create-home --shell /bin/false consul
        mkdir -p /var/consul/data
        chown -R consul:consul /var/consul/
        mkdir /etc/consul.d
        cp /vagrant/consul-client.json /etc/consul.d/consul.json
        cp /vagrant/consul.service /etc/systemd/system/
        cp /vagrant/consul /usr/bin/

        useradd --no-create-home --shell /bin/false vault
        mkdir /etc/vault.d/
        cp /vagrant/vault.hcl /etc/vault.d/
        cp /vagrant/vault.service /etc/systemd/system
        cp /vagrant/vault /usr/bin/
        export VAULT_ADDR="http://127.0.0.1:8200"
      SHELL

      retry_joins = cluster_ips.map { |ip| "\"#{ip}\"" }.join(', ')
      replace_node_name = "sed -i 's/$NODE_NAME/#{box_hostname}/g' /etc/consul.d/consul.json"
      replace_bind_addr = "sed -i 's/$BIND_ADDR/#{node_ip}/' /etc/consul.d/consul.json"
      replace_all_retry_joins = "sed -i 's/\"$RETRY_JOINS\"/[#{retry_joins}]/' /etc/consul.d/consul.json"
      replace_vault_ip_addr = "sed -i 's/$API_ADDR/#{node_ip}/' /etc/vault.d/vault.hcl"

      db.vm.provision :shell, run: 'once', inline: replace_node_name
      db.vm.provision :shell, run: 'once', inline: replace_bind_addr
      db.vm.provision :shell, run: 'once', inline: replace_all_retry_joins
      db.vm.provision :shell, run: 'once', inline: replace_vault_ip_addr

      db.vm.provision "shell", run: "once", inline: <<-SHELL
        systemctl daemon-reload
        systemctl enable consul.service
        systemctl start consul.service
        systemctl status consul.service
        systemctl enable vault.service
        systemctl start vault.service
        systemctl status vault.service
      SHELL
    end
  end
end
