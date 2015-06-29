#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
is_master_ldap: TRUE
do_create_domain: yes
ldap_rid: 100
ldap_url: "ldap://ldap02.{{ client_name }}.{{ datacenter }}.synacor.com:389/ ldap://ldap01.{{ client_name }}.{{ datacenter }}.synacor.com:389/"
install_packages: zimbra-core zimbra-ldap
