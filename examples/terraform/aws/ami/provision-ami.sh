#!/bin/bash

_apt_opts="sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
_apt_install_cmd="${_apt_opts} install"
_apt_upgrade_cmd="${_apt_opts} dist-upgrade"

ssh_auth_key_file="/root/.ssh/authorized_keys"
ssh_root_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi6UIVruH0CfKewYlSjA7oR6gjahZrkJ+k/0cj46nvYrORVcds2cijZPT34ACWkvXV8oYvXGWmvlGXV5H1sD0356zpjhRnGo6j4UZVS6KYX5HwObdZ6H/i+A9knEyXxOCyo6p4VeJIYGhVYcQT4GDAkxb8WXHVP0Ax/kUqrKx0a2tK9JjGkuLbufQc3yWhqcfZSVRU2a+M8f8EUmGLOc2VEi2mGoxVgikrelJ0uIGjLn63L6trrsbvasoBuILeXOAO1xICwtYFek/MexQ179NKqQ1Wx/+9Yx4Xc63MB0vR7kde6wxx2Auzp7CjJBFcSTz0TXSRsvF3mnUUoUrclNkr voa@auth.shalb.com"

# deploy configs (preinstall)
sudo chown -R root:root /tmp/root_sync_preinstall
sudo rsync -av /tmp/root_sync_preinstall/ /

# add ssh pubkey for root user
sudo sed -i "\$a${ssh_root_pubkey}" "${ssh_auth_key_file}"

# upgrade all packages
sudo apt-get update
${_apt_upgrade_cmd}

# install additional soft
${_apt_install_cmd} htop atop mtr sysstat tcptraceroute nload unzip iotop apt-file unzip mysql-client jq ntp

# Docker
${_apt_install_cmd} apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
${_apt_install_cmd} docker-ce

echo "Configuring Docker..."
sudo groupadd docker
sudo usermod -aG docker ubuntu
sudo service docker restart
sudo chmod 777 /var/run/docker.sock
docker run hello-world || exit 1

echo "Installing docker-compose..."
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version || exit 1

# Init base images
docker pull osixia/openldap:1.2.1
docker pull osixia/phpldapadmin:0.7.1
docker pull odavid/my-bloody-jenkins
docker pull sonatype/nexus3


# Monit
# sudo mkdir -p /var/log/monit /etc/monit.d /root/monit

# Postfix
echo "postfix postfix/mailname string example.com" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
${_apt_install_cmd} postfix mailutils mutt

# Oracle Java
sudo apt-add-repository -y ppa:webupd8team/java
sudo apt-get update
echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | sudo /usr/bin/debconf-set-selections
${_apt_install_cmd} oracle-java8-installer

# clear logs
sudo rm -rf /var/log/*/*

# Install Filebeat
wget -O - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get update
${_apt_install_cmd} filebeat

#--------------- POST INSTALL ACTIONS ------------
# deploy configs (post-install)
sudo chown -R root:root /tmp/root_sync
sudo rsync -av /tmp/root_sync/ /

sudo chown -R ubuntu:ubuntu /home/ubuntu
