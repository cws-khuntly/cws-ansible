#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
## These variables will be used to generate the unattended installation options file
## Change to suit environment
build_type: MessageSystems Cluster Manager
server_type: ecmgr
manager_ipaddr: "{{ hostvars[inventory_hostname]['ansible_eth0']['ipv4']['address'] }}"

inbound_hosts:
  - name: "mx01.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 1.2.3.4
  - name: "mx02.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 4.3.2.1

outbound_hosts:
  - name: "smtp01.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 2.1.3.4
  - name: "smtp02.{{ client_name }}.{{ datacenter }}.synacor.com"
    address: 4.1.2.3

##
## installer options
##
mobility: n
db_init: y
is_mta: n
scope: n
database: 1
web: 1
mta: 0
manager: 1
