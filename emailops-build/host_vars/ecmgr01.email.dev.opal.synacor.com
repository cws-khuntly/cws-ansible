#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
## These variables will be used to generate the unattended installation options file
## Change to suit environment
build_type: MessageSystems Cluster Manager
server_type: ecmgr
is_ecmgr: TRUE
db_init: y
database: 1
web: 1
mta: 0
manager: 1

##
## subversion!
##
svn_host: "https://ecmgr01.{{ client_name }}.{{ datacenter }}.synacor.com:2027/config/manager/boot"

##
## installer conf
##
db_root: /var/db/msyspg

inbound_hosts:
  - name: "mx01.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 10.250.27.174
  - name: "mx02.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 10.250.27.175

outbound_hosts:
  - name: "smtp01.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 10.250.27.176
  - name: "smtp02.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 10.250.27.177
