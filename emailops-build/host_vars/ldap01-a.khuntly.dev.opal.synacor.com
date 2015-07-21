#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
is_master_ldap: TRUE
do_create_domain: yes
ldap_rid: 100
promote: FALSE
apply_global_config: TRUE

##
## LDAP host url's
##
ldap_url: "ldap://ldap01-a.{{ client_name }}.{{ datacenter }}.synacor.com:389/ ldap://ldap01-b.{{ client_name }}.{{ datacenter }}.synacor.com:389/"
