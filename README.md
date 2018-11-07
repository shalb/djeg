Product name: DJEG

Abbreviation for Docker Jenkins Elasticsearch Grafana.

Product summary:

Integrated system for the full cycle product development, from the source code to operational environments.
Aggregates best DevOps and SRE practices.
Preconfigured: Continuous Integration, Testing and Delivery, Log Aggregation,
Monitoring, Alerting, Cetralized account management.
Requires only 15 minutes to deploy instead of 3-6 month of integration.

Product use-case:

Deploy a CI/CD systems (Jenkins, Sprinnaker, Nexus) from scretch using scripts.
Complete development infrastructure installation with IaaC(Infrastructure as a Code) approach.
Centralized user management for all integrated systems using OpenLDAP.
"ELK"-stack deployment for services and CI/CD jobs logging. 
Alerting with Elasalert to notify developers on logs events on any environment.
Notification to Slack, Email or any other channels.
Deploy metrics and monitoring with Prometheus and Grafana with service autoconfiguration.
Templated infrastructure patterns with Terraform.
Deployment to any platform like AWS, Google Cloud, Kubernetes, Azure, Openstack.

# Djeg

Contains the following services:
* ldap - a simple [Openldap server](https://github.com/osixia/docker-openldap) that is prepopluated on startup using [custom.ldif](examples/custom-conf/ldap/custom.ldif)
* ldap-admin - a simple ldap php admin for managing ldap [Php ldap admin](https://github.com/osixia/docker-phpLDAPadmin)
* jenkins - My Bloody jenkins that watches changes from custom configs set: [Bloody jenkins](https://github.com/odavid/my-bloody-jenkins)
* nexus - Sonatype Nexus Repository Manager 3, from [Nexus](https://hub.docker.com/r/sonatype/nexus3/)
* registry - nexus hosted docker repo: [Nexus registry](https://help.sonatype.com/repomanager3/private-registry-for-docker)
* nginx_env_proxy - nginx proxy service with LE SSL automation (see description below)
* static jenkins slave with the possibility of customization. [Dockerfile](examples/custom-conf/images/jslave-common/Dockerfile)

## Prerequisites
* docker in swarm mode
* Real ip address available from the Internet.
* Opened ports 80 and 443.
* DNS record for the base DJEG domain, pointing to the server IP address:
  *.djeg.example.com. IN A xx.xx.xx.xx
  Or individual A records with same IP for all domains in [config.env](examples/custom-conf/config.env)

## Starting up stack

**1) Clone djeg repo:**
```shell
git clone https://github.com/shalb/djeg /opt/djeg
```

**2) Create custom configuration from example:**
```shell
cp -r /opt/djeg/examples/custom-conf/ /etc/djeg/
```

**3) Edit main config [config.env](examples/custom-conf/config.env) like this:**
```shell
cat << EOF > /etc/djeg/config.env
DJEG_JENKINS_HOST_FQDN=jenkins.djeg.example.org
DJEG_REGISTRY_HOST_FQDN=registry.djeg.example.org
DJEG_NEXUS_HOST_FQDN=nexus.djeg.example.org
DJEG_LDAP_ADMIN_HOST_FQDN=ldap-admin.djeg.example.org

LDAP_DOMAIN=example.org
LDAP_BASE_DN=dc=example,dc=org

DJEG_NEXUS_DATA_DIR=/data/djeg/nexus
DJEG_JENKINS_DATA_DIR=/data/djeg/jenkins

DJEG_NGINX_SSL_DIR=/data/djeg/ssl

EOF
```

**4) Edit users and privileges settings [custom.ldif](examples/custom-conf/ldap/custom.ldif):**
```shell
vim /etc/djeg/ldap/custom.ldif
```
(for testing, you could use default example file)

**5) Add jenkins credentials [02-credentials.yml](examples/custom-conf/jenkins/02-credentials.yml):**
```shell
vim /etc/djeg/jenkins/02-credentials.yml
```
(for testing, you could use default example file)

**6) Edit multibranch pipeline job [03-job-multibrunch.yml](examples/custom-conf/jenkins/03-job-multibrunch.yml):**
```shell
vim /etc/djeg/jenkins/03-job-multibrunch.yml
```

**7) Add the necessary software to jenkins slave container [Dockerfile](examples/custom-conf/images/jslave-common/Dockerfile):**
```shell
vim /etc/djeg/images/jslave-common/Dockerfile
```
(for testing, you could use default example file)

**8) Set custom configuration path and start djeg:**
```shell
cd /opt/djeg/
export DJEG_CUSTOM_CONF_DIR="/etc/djeg/"
./bootstrap.sh
```