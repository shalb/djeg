#!/bin/bash

_apt_opts="sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
_apt_install_cmd="$_apt_opts install"
_apt_upgrade_cmd="$_apt_opts dist-upgrade"

datadir=/data
soft_datadir=/opt/djeg
JENKINS_HOME=$soft_datadir

main() {
  data_volume_process
  create_fs_paths
  hostname_gen
  additional_software_install
  daemons_start
  deploy_djeg
}


data_volume_process() {
  while [[ ! -b ${disk} ]]; do echo "Waiting until ${disk} be attached..."; sleep 5; done

  if ! lsblk --noheadings --output="NAME" "${disk}1"; then
    /sbin/sgdisk --new=1:2048 --typecode=1:8300 --change-name=1:"DJEG Data" ${disk}
    /sbin/mkfs.ext4 "${disk}1"
  fi

  if [[ ! -d $datadir ]]; then
    mkdir "$datadir"
  fi

  echo "${disk}1 /data ext4 defaults,noatime,discard 0 0" >> /etc/fstab
  mount -a
}

create_fs_paths() {
  if [[ ! -d $soft_datadir ]]; then
    mkdir -p $soft_datadir
  fi
  if [[ ! -d $datadir$soft_datadir ]]; then
    mkdir -p "$datadir$soft_datadir"
  fi
  echo "$datadir$soft_datadir $soft_datadir none bind 0 0" >> /etc/fstab
  mount -a
}

hostname_gen() {
  echo "Hostname generation"
  hostname "${instancehostname}" && hostname > /etc/hostname
  echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
}

additional_software_install() {
echo "Adding Python deps"
$_apt_install_cmd -y python3-pip ntpd
}

deploy_djeg(){
# clone repo
git clone https://github.com/shalb/djeg /opt/djeg
# checkout specific version
pushd /opt/djeg; git checkout tags/${djeg_version}

# create a sample configuration ||
## !! better choice download from own repo with own version
## !! git clone https://github.com/mysuperproject/djeg-custom/ /etc/djeg/
cp -r /opt/djeg/examples/custom-conf/ /etc/djeg/

## Define domain from terraform
sed -i 's/example.org/${instancehostname}/g' /opt/djeg/swarm/config.env

##Init Swarm
docker swarm init

#Build base images and start stack
cd /opt/djeg/
export DJEG_CUSTOM_CONF_DIR="/etc/djeg/"
./bootstrap.sh

}

daemons_start() {#!/bin/bash

_apt_opts="sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
_apt_install_cmd="$_apt_opts install"
_apt_upgrade_cmd="$_apt_opts dist-upgrade"

datadir=/data
soft_datadir=/opt/djeg
JENKINS_HOME=$soft_datadir

main() {

  data_volume_process
  create_fs_paths
  hostname_gen
  additional_software_install
  daemons_start
  deploy_djeg
}


data_volume_process() {
  while [[ ! -b ${disk} ]]; do echo "Waiting until ${disk} be attached..."; sleep 5; done

  if ! lsblk --noheadings --output="NAME" "${disk}1"; then
    /sbin/sgdisk --new=1:2048 --typecode=1:8300 --change-name=1:"ELK Data" ${disk}
    /sbin/mkfs.ext4 "${disk}1"
  fi

  if [[ ! -d $datadir ]]; then
    mkdir "$datadir"
  fi

  echo "${disk}1 /data ext4 defaults,noatime,discard 0 0" >> /etc/fstab
  mount -a
}

create_fs_paths() {
  if [[ ! -d $soft_datadir ]]; then
    mkdir -p $soft_datadir
  fi
  if [[ ! -d $datadir$soft_datadir ]]; then
    mkdir -p "$datadir$soft_datadir"
  fi
  echo "$datadir$soft_datadir $soft_datadir none bind 0 0" >> /etc/fstab
  mount -a
}

hostname_gen() {
  echo "Hostname generation"
  hostname "${instancehostname}" && hostname > /etc/hostname
  echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
}

additional_software_install() {
echo "Adding Python deps"
$_apt_install_cmd -y python3-pip
pip3 install pycrypto
pip3 install deepdiff
pip3 install telepot
pip3 install pyserial
pip3 install pymysql
}

deploy_djeg(){
#Download Djeg

ssh-keyscan gitlab.shalb.com >>  ~/.ssh/known_hosts
git clone https://reader:reader123@gitlab.shalb.com/shalb/djeg/ /opt/djeg
#checkout specific version
pushd /opt/djeg; git checkout tags/${djeg_version}

## Define domain from terraform
sed -i 's/djeg-test.shalb.com/${instancehostname}/g' /opt/djeg/swarm/config.env

##Init Swarm
docker swarm init

# Download IaC repo
git clone https://reader:reader123@gitlab.shalb.com/shalb/celebtv-iac /data/conf

#Build base images and start stack
pushd /opt/djeg/swarm/builds/; ./build.sh; popd;
ln -s  /opt/djeg/swarm/config.env /data/conf/ci/swarm/config.env
cp /opt/djeg/swarm/daemon.json /data/conf/ci/swarm/
pushd /data/conf/ci/swarm/; docker stack deploy -c stack.yml djeg; popd

#Build  custom images
pushd /data/conf/ci/swarm/images; ./build.sh; popd;

}

daemons_start() {
systemctl enable ntp.service
systemctl restart ntp.service

systemctl enable postfix
systemctl restart postfix

}


main