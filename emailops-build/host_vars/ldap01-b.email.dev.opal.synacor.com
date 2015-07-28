#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
is_master_ldap: FALSE
do_create_domain: no
ldap_rid: 200
promote: TRUE
apply_global_config: FALSE

##
## LDAP host url's
##
ldap_url: "ldap://ldap01-b.{{ client_name }}.{{ datacenter }}.synacor.com:389/ ldap://ldap01-a.{{ client_name }}.{{ datacenter }}.synacor.com:389/"
