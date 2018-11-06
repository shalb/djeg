#!/bin/bash

#STACK_NAME="djeg"
#DJEG_NEXUS_HOST_FQDN=$(docker service inspect --format '{{ range .Spec.TaskTemplate.ContainerSpec.Env }}{{println .}}{{end}}' ${STACK_NAME}_nginx | grep "DJEG_NEXUS_HOST_FQDN" | awk -F '=' '{print $2}')
NEXUS_USER="admin"
NEXUS_PASS="admin123"

cd /scripts/

function groovy_to_json {
  GROOVY_DATA=""
  while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
    [ ! -z "${GROOVY_DATA}" ] && GROOVY_DATA="${GROOVY_DATA};"
    GROOVY_DATA="${GROOVY_DATA} ${LINE}"
  done < "${GROOVY_FILE}"

  echo "{
  \"name\": \"${SCRIPT_NAME}\",
  \"type\": \"groovy\",
  \"content\": \"${GROOVY_DATA}\"
}" > ${SCRIPT_FILE}

}

function read_script_file {
  SCRIPT_NAME=$(cat ./${SCRIPT_FILE} 2>/dev/null | jq .name 2>/dev/null | cut -d '"' -f 2)
  [[ -z "${SCRIPT_NAME}" ]] && echo "ERROR: Corrupted script file \"${SCRIPT_FILE}\"." && exit 1
}

function delete_script {
  printf "Remove script ${SCRIPT_NAME} if exists: "
  RES=$(curl -X DELETE -u ${NEXUS_USER}:${NEXUS_PASS} --write-out %{http_code} --silent --output /dev/null "${NEXUS_URL}/service/rest/v1/script/${SCRIPT_NAME}")
  echo ${RES}
}

function add_script {
    printf "Uploading script ${SCRIPT_NAME} from filr ${SCRIPT_FILE}: "
    RES=$(curl -X POST -u ${NEXUS_USER}:${NEXUS_PASS} --header "Content-Type: application/json" --write-out %{http_code} --silent --output /dev/null  "${NEXUS_URL}/service/rest/v1/script" -d @${SCRIPT_FILE})
    echo ${RES}
}

function run_script {
   printf "Run script ${SCRIPT_NAME}: "
   RES=$(curl -X POST -u ${NEXUS_USER}:${NEXUS_PASS} --header "Content-Type: text/plain"  --write-out %{http_code} --silent --output /dev/null "${NEXUS_URL}/service/rest/v1/script/${SCRIPT_NAME}/run")
   echo ${RES}

}
NEXUS_URL="https://${DJEG_NEXUS_HOST_FQDN}"

# Gen admin password.
ADMIN_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
sed -i "s|#ADMIN_PASS#|${ADMIN_PASS}|g" ./99_change_pass.groovy
sed -i "s|#LDAP_BASE_DN#|${LDAP_BASE_DN}|g" ./02_create_ldap.groovy
sed -i "s|#LDAP_BASE_DN#|${LDAP_BASE_DN}|g" ./02_create_ldap.groovy

echo "Nexus admin password: ${ADMIN_PASS}"

echo "Waiting for nexus redy..."
while true; do
 # break
 printf " Checking nexus API: "
 RESP=$(curl -X GET -u ${NEXUS_USER}:${NEXUS_PASS} --write-out %{http_code} --silent --output /dev/null ${NEXUS_URL}/service/rest/v1/script)
 if [[ "${RESP}" -ne 200 ]]; then
   echo "fail"
 else 
   echo "ok"
   break
 fi
 sleep 5
done

# Searching scripts by pattern. Creating lists.
while read FILE_NAME
do
    if [[ "${FILE_NAME}" =~ ^([[:digit:]]{2}_)(.*)\.groovy$ ]]; then
      SCRIPT_NAME="${BASH_REMATCH[2]}"
      SCRIPT_FILE="${BASH_REMATCH[1]}${BASH_REMATCH[2]}.json"
      GROOVY_FILE="${FILE_NAME}"
      groovy_to_json
      read_script_file
      delete_script
      add_script
      run_script
      rm ./${SCRIPT_FILE}
    fi
done < <(ls | sort -s )

