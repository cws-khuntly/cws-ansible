#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
## These variables will be used to generate the unattended installation options file
## Change to suit environment
build_type: MessageSystems SMTP Server
server_type: smtp

##
## subversion!
##
svn_host: "https://ecmgr01.{{ client_name }}.{{ datacenter }}.synacor.com:2027/config/outbound/boot"
