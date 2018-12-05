import groovy.json.JsonOutput
import org.sonatype.nexus.ldap.persist.LdapConfigurationManager
import org.sonatype.nexus.ldap.persist.entity.Connection
import org.sonatype.nexus.ldap.persist.entity.LdapConfiguration
import org.sonatype.nexus.ldap.persist.entity.Mapping
import org.sonatype.nexus.security.user.UserSearchCriteria
import groovy.json.JsonSlurper

ldapManager = container.lookup(LdapConfigurationManager.class.name)

def connection_host = new Connection.Host(Connection.Protocol.ldap, 'ldap', 389)
def connection = new Connection(host: connection_host, maxIncidentsCount: 30, connectionRetryDelay: 300, connectionTimeout: 3, searchBase: '#LDAP_BASE_DN#', authScheme: 'simple', systemPassword: 'readonly', systemUsername: 'cn=readonly,#LDAP_BASE_DN#')
def mapping = new Mapping(userBaseDn: 'ou=users', userObjectClass: 'inetOrgPerson', ldapFilter: '', userIdAttribute: 'uid', userRealNameAttribute: 'cn', emailAddressAttribute: 'Email', userPasswordAttribute: '', ldapGroupsAsRoles: true, userMemberOfAttribute: 'memberOf',)
def ldapconf = new LdapConfiguration(name: 'autildap', connection: connection, mapping: mapping)

ldapManager.addLdapServerConfiguration(ldapconf)
