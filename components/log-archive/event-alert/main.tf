data "alicloud_log_alert_resource" "init" {
  provider = alicloud.sls_project
  type     = "user"
  lang     = var.lang == "en-US" ? "en" : "cn"
}

resource "alicloud_log_resource_record" "user" {
  for_each = {
    for user in var.users : user.id => user
  }
  provider      = alicloud.sls_resource_record
  resource_name = "sls.common.user"
  record_id     = each.key
  tag           = each.value.name
  value = jsonencode({
    user_id       = each.key
    user_name     = each.value.name
    sms_enabled   = try(each.value.sms_enabled, null)
    phone         = try(each.value.phone, null)
    voice_enabled = try(each.value.voice_enabled, null)
    email         = try(each.value.email, [])
    enabled       = try(each.value.enabled, true)
    country_code  = try(each.value.country_code, null)
  })
}

locals {
  user_ids = [
    for user in var.users : user.id
  ]

  user_group_ids = [
    for g in var.user_groups : g.id
  ]

  default_template_id = var.lang == "en-US" ? "sls.app.actiontrail.builtin.en" : "sls.app.actiontrail.builtin.cn"

  primary_policy_script_lines = [
    for a in var.action_policy_scripts :
    format(
      "fire(type=\"%s\", users=%s, groups=%s, template_id=\"%s\", period=\"%s\")",
      a.type,
      jsonencode(a.users),
      jsonencode(a.groups),
      coalesce(a.template_id, local.default_template_id),
      a.period
    )
  ]

  primary_policy_script = join("\n", local.primary_policy_script_lines)
}

resource "alicloud_log_resource_record" "user_group" {
  for_each = {
    for g in var.user_groups : g.id => g
  }

  provider      = alicloud.sls_resource_record
  resource_name = "sls.common.user_group"
  record_id     = each.value.id
  tag           = each.value.name
  value = jsonencode({
    user_group_id   = each.value.id
    user_group_name = each.value.name
    enabled         = true
    members         = each.value.use_all_users ? local.user_ids : each.value.user_ids
  })

  depends_on = [alicloud_log_resource_record.user]
}

resource "alicloud_log_resource_record" "action_policy" {
  count         = var.use_existing_action_policy ? 0 : 1
  provider      = alicloud.sls_resource_record
  resource_name = "sls.alert.action_policy"
  record_id     = var.action_policy_id
  tag           = coalesce(var.action_policy_name, var.action_policy_id)
  value = jsonencode({
    action_policy_id      = var.action_policy_id
    action_policy_name    = coalesce(var.action_policy_name, var.action_policy_id)
    labels                = {}
    is_default            = false
    primary_policy_script = local.primary_policy_script
  })

  depends_on = [alicloud_log_resource_record.user_group]
}
