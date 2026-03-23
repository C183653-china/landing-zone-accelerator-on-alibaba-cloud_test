provider "alicloud" {
  alias  = "sls_project"
  region = "cn-hangzhou"
}

provider "alicloud" {
  alias  = "sls_resource_record"
  region = "cn-heyuan"
}

module "event_alert" {
  source = "../../../../components/log-archive/event-alert"

  providers = {
    alicloud.sls_project         = alicloud.sls_project
    alicloud.sls_resource_record = alicloud.sls_resource_record
  }

  project_name  = "log-archive-example"
  logstore_name = "actiontrail_log-archive"
  lang          = "zh-CN"

  users = [
    {
      id    = "user.first"
      name  = "First User"
      email = ["first@example.com"]
    },
    {
      id            = "user.secondary"
      name          = "Secondary User"
      phone         = "18800000000"
      country_code  = "86"
      sms_enabled   = true
      voice_enabled = false
      email         = ["secondary@example.com"]
    }
  ]

  user_groups = [
    {
      id            = "group_example"
      name          = "Example Group"
      user_ids      = ["user.first"]
      use_all_users = false
    },
    {
      id            = "group_ops"
      name          = "Ops Group"
      user_ids      = ["user.secondary"]
      use_all_users = false
    }
  ]

  use_existing_action_policy = false
  action_policy_id           = "policy_example"
  action_policy_name         = "example_policy"

  action_policy_scripts = [
    {
      type   = "email"
      users  = []
      groups = ["group_example"]
      period = "any"
    },
    {
      type   = "sms"
      users  = ["user.secondary"]
      groups = []
      period = "workday"
    },
    {
      type   = "voice"
      users  = []
      groups = ["group_ops"]
      period = "non_worktime"
    }
  ]

  enabled_alerts = [
    "cis.at.abnormal_login",
    "cis.at.root_login",
    "ip_insight_v2",
    "cis.at.vpc_flowlog_off",
    "cis.at.ram_mfa_login"
  ]
}

