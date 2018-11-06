#!/bin/bash

set -x
set -e

DJEG_DIR=$(readlink -f "$(dirname "$0")")

. ${DJEG_CUSTOM_CONF_DIR}/config.env
mkdir -p ${DJEG_NEXUS_DATA_DIR} ${DJEG_JENKINS_DATA_DIR} ${DJEG_NGINX_SSL_DIR}
chmod 777 ${DJEG_NEXUS_DATA_DIR} ${DJEG_JENKINS_DATA_DIR} ${DJEG_NGINX_SSL_DIR}
export DJEG_NEXUS_DATA_DIR="${DJEG_NEXUS_DATA_DIR}"
export DJEG_JENKINS_DATA_DIR="${DJEG_JENKINS_DATA_DIR}"
export DJEG_NGINX_SSL_DIR="${DJEG_NGINX_SSL_DIR}"

cp jenkins/ldap.tmpl jenkins/ldap.yml
sed -i "s|#LDAP_BASE_DN#|${LDAP_BASE_DN}|g" jenkins/ldap.yml

cd ${DJEG_DIR}/images/

for NAME in `ls -1`; do
   echo "Building ${NAME}:"
   docker build -t ${NAME} ./${NAME}/
done

cd ${DJEG_CUSTOM_CONF_DIR}/images/

for NAME in `ls -1`; do
   echo "Building ${NAME}:"
   docker build -t ${NAME} ./${NAME}/
done

cd ${DJEG_DIR}/
echo "Deploying base stack:"
docker stack deploy -c stack.yml djeg --with-registry-auth

cd ${DJEG_CUSTOM_CONF_DIR}/swarm/
for NAME in `ls -1`; do
   echo "Deploying ${NAME}:"
   docker stack deploy -c ${NAME} djeg --with-registry-auth
done
