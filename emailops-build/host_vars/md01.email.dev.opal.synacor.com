#=====  ANSIBLE   =============================================================
#          NAME:  host_vars/${HOSTNAME}
#   DESCRIPTION:  Configuration file for specific target host within playbook
#==============================================================================
---
apply_global_config: TRUE
apply_domains: TRUE
apply_cos: TRUE
