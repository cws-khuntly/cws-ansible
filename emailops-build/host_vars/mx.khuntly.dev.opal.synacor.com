#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
## These variables will be used to generate the unattended installation options file
## Change to suit environment
build_type: MessageSystems Console MX server
server_type: mx

##
## ssl certs
##
self_signed_enabled: TRUE
openssl_self_signed:
  - name: 'mx.{{ domain }}'
    domain_name: 'mx.{{ domain }}'
    country: 'US'
    state: 'New York'
    city: 'Buffalo'
    organization: 'Synacor, Inc.'
    unit: 'Email Operations'
    email: 'emailops@synacor.com'
    days: 90

##
## JIRA
##
jira_summary: "Request for MX VIP: {{ client_name }}/{{ datacenter }}"
jira_description: "Please create mx.{{ client_name }}.{{ datacenter }} .caspersbox.comVIP with targets {{ address }}"
