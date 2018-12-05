#!/bin/bash

CONF_NAME="/etc/nginx/conf.d/configs/env.conf"
LDAP_INCLUDE_NAME="/etc/nginx/auth_proxy_ldap"

[ -z "${DJEG_JENKINS_HOST_FQDN}" ] && echo "ERROR: DJEG_JENKINS_HOST_FQDN variable is empty!" && exit 1
[ -z "${DJEG_REGISTRY_HOST_FQDN}" ] && echo "ERROR: DJEG_REGISTRY_HOST_FQDN variable is empty!" && exit 1
[ -z "${DJEG_NEXUS_HOST_FQDN}" ] && echo "ERROR: DJEG_NEXUS_HOST_FQDN variable is empty!" && exit 1
[ -z "${DJEG_LDAP_ADMIN_HOST_FQDN}" ] && echo "ERROR: DJEG_LDAP_ADMIN_HOST_FQDN variable is empty!" && exit 1

DOMAINS_LIST="${DJEG_JENKINS_HOST_FQDN},${DJEG_REGISTRY_HOST_FQDN},${DJEG_NEXUS_HOST_FQDN},${DJEG_LDAP_ADMIN_HOST_FQDN}"

sed -i "s|#DJEG_JENKINS_HOST_FQDN#|${DJEG_JENKINS_HOST_FQDN}|g" ${CONF_NAME}
sed -i "s|#DJEG_REGISTRY_HOST_FQDN#|${DJEG_REGISTRY_HOST_FQDN}|g" ${CONF_NAME}
sed -i "s|#DJEG_NEXUS_HOST_FQDN#|${DJEG_NEXUS_HOST_FQDN}|g" ${CONF_NAME}
sed -i "s|#DJEG_LDAP_ADMIN_HOST_FQDN#|${DJEG_LDAP_ADMIN_HOST_FQDN}|g" ${CONF_NAME}
sed -i "s|#LDAP_BASE_DN#|${LDAP_BASE_DN}|g" ${LDAP_INCLUDE_NAME}


#while true; do
#sleep 2
#done
ssl_processing.sh ${DOMAINS_LIST} &

/usr/sbin/nginx -g "daemon off;"

