output "user_ids" {
  value = {
    for user_id, record in alicloud_log_resource_record.user :
    user_id => record.id
  }
}

output "user_group_ids" {
  value = {
    for group_id, record in alicloud_log_resource_record.user_group :
    group_id => record.id
  }
}

output "action_policy_id" {
  value = try(alicloud_log_resource_record.action_policy[0].id, null)
}

output "alert_ids" {
  value = {
    "ip_insight"                         = try(alicloud_log_alert.ip_insight[0].id, null)
    "ip_insight_v2"                      = try(alicloud_log_alert.ip_insight_v2[0].id, null)
    "db.at.rds_instance_del"             = try(alicloud_log_alert.db_at_rds_instance_del[0].id, null)
    "dataflow.at.slb_http"               = try(alicloud_log_alert.dataflow_at_slb_http[0].id, null)
    "cis.at.vpc_route_change"            = try(alicloud_log_alert.cis_at_vpc_route_change[0].id, null)
    "cis.at.vpc_flowlog_off"             = try(alicloud_log_alert.cis_at_vpc_flowlog_off[0].id, null)
    "cis.at.vpc_conf_change"             = try(alicloud_log_alert.cis_at_vpc_conf_change[0].id, null)
    "cis.at.unauth_login"                = try(alicloud_log_alert.cis_at_unauth_login[0].id, null)
    "cis.at.unauth_apicall"              = try(alicloud_log_alert.cis_at_unauth_apicall[0].id, null)
    "cis.at.trail_off"                   = try(alicloud_log_alert.cis_at_trail_off[0].id, null)
    "cis.at.abnormal_login"              = try(alicloud_log_alert.cis_at_abnormal_login[0].id, null)
    "cis.at.abnormal_ak_usage"           = try(alicloud_log_alert.cis_at_abnormal_ak_usage[0].id, null)
    "cis.at.pwd_login_attemp_policy"     = try(alicloud_log_alert.cis_at_pwd_login_attemp_policy[0].id, null)
    "cis.at.abnormal_pwd_mod_cnt"        = try(alicloud_log_alert.cis_at_abnormal_pwd_mod_cnt[0].id, null)
    "cis.at.pwd_expire_policy"           = try(alicloud_log_alert.cis_at_pwd_expire_policy[0].id, null)
    "cis.at.pwd_length_policy"           = try(alicloud_log_alert.cis_at_pwd_length_policy[0].id, null)
    "cis.at.pwd_reuse_prevention_policy" = try(alicloud_log_alert.cis_at_pwd_reuse_prevention_policy[0].id, null)
    "cis.at.password_reset"              = try(alicloud_log_alert.cis_at_password_reset[0].id, null)
    "cis.at.password_change"             = try(alicloud_log_alert.cis_at_password_change[0].id, null)
    "cis.at.root_login"                  = try(alicloud_log_alert.cis_at_root_login[0].id, null)
    "cis.at.root_ak_usage"               = try(alicloud_log_alert.cis_at_root_ak_usage[0].id, null)
    "cis.at.ram_mfa_login"               = try(alicloud_log_alert.cis_at_ram_mfa_login[0].id, null)
    "cis.at.ram_auth_change"             = try(alicloud_log_alert.cis_at_ram_auth_change[0].id, null)
    "cis.at.ram_policy_change"           = try(alicloud_log_alert.cis_at_ram_policy_change[0].id, null)
    "cis.at.rds_access_whitelist"        = try(alicloud_log_alert.cis_at_rds_access_whitelist[0].id, null)
    "cis.at.rds_sql_audit"               = try(alicloud_log_alert.cis_at_rds_sql_audit[0].id, null)
    "cis.at.rds_ssl_config"              = try(alicloud_log_alert.cis_at_rds_ssl_config[0].id, null)
    "cis.at.rds_conf_change"             = try(alicloud_log_alert.cis_at_rds_conf_change[0].id, null)
    "cis.at.oss_policy_change"           = try(alicloud_log_alert.cis_at_oss_policy_change[0].id, null)
    "cis.at.sas_webshell_unbind"         = try(alicloud_log_alert.cis_at_sas_webshell_unbind[0].id, null)
    "cis.at.sas_webshell_detection"      = try(alicloud_log_alert.cis_at_sas_webshell_detection[0].id, null)
    "cis.at.esc_release"                 = try(alicloud_log_alert.cis_at_esc_release[0].id, null)
    "cis.at.ecs_release_protec_off"      = try(alicloud_log_alert.cis_at_ecs_release_protec_off[0].id, null)
    "cis.at.ecs_reboot_alot"             = try(alicloud_log_alert.cis_at_ecs_reboot_alot[0].id, null)
    "cis.at.ecs_force_reboot"            = try(alicloud_log_alert.cis_at_ecs_force_reboot[0].id, null)
    "cis.at.ecs_disk_release"            = try(alicloud_log_alert.cis_at_ecs_disk_release[0].id, null)
    "cis.at.ecs_disk_reinit"             = try(alicloud_log_alert.cis_at_ecs_disk_reinit[0].id, null)
    "cis.at.ecs_disk_encry_detc"         = try(alicloud_log_alert.cis_at_ecs_disk_encry_detc[0].id, null)
    "cis.at.ecs_auto_snapshot_policy"    = try(alicloud_log_alert.cis_at_ecs_auto_snapshot_policy[0].id, null)
    "cis.at.securitygroup_change"        = try(alicloud_log_alert.cis_at_securitygroup_change[0].id, null)
    "cis.at.cloudfirewall_conf_change"   = try(alicloud_log_alert.cis_at_cloudfirewall_conf_change[0].id, null)
    "cis.at.cfw_basic_rule_off"          = try(alicloud_log_alert.cis_at_cfw_basic_rule_off[0].id, null)
    "cis.at.cfw_ai_off"                  = try(alicloud_log_alert.cis_at_cfw_ai_off[0].id, null)
    "cis.at.cfw_ti_off"                  = try(alicloud_log_alert.cis_at_cfw_ti_off[0].id, null)
    "cis.at.cfw_patch_off"               = try(alicloud_log_alert.cis_at_cfw_patch_off[0].id, null)
    "cis.at.cfw_log_off"                 = try(alicloud_log_alert.cis_at_cfw_log_off[0].id, null)
    "cis.at.cfw_obs_mode"                = try(alicloud_log_alert.cis_at_cfw_obs_mode[0].id, null)
    "cis.at.cfw_loose_block"             = try(alicloud_log_alert.cis_at_cfw_loose_block[0].id, null)
    "cis.at.cfw_assets_protec_off"       = try(alicloud_log_alert.cis_at_cfw_assets_protec_off[0].id, null)
    "cis.at.cfw_assets_auto_protec_off"  = try(alicloud_log_alert.cis_at_cfw_assets_auto_protec_off[0].id, null)
    "cis.at.api_err"                     = try(alicloud_log_alert.cis_at_api_err[0].id, null)
    "cis.at.ak_conf_change"              = try(alicloud_log_alert.cis_at_ak_conf_change[0].id, null)
  }
}
