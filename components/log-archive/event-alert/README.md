## Event Alert Component

This component creates and manages Alibaba Cloud SLS ActionTrail event alerts based on predefined alert templates, users, user groups, and action policies.

### Features

- Creates SLS resource records for alert users and user groups
- Creates SLS action policy to control how alerts are delivered (email/SMS/voice)
- Creates SLS alerts for a rich set of ActionTrail-based security and compliance rules
- Supports multiple user groups and per-group membership configuration
- Supports using an existing action policy instead of creating a new one

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | ~> 1.267 |

> **Important:** If you need to **see the alerts in the ActionTrail console**, you must **manually enable the Event Alert feature** in the ActionTrail console (for example, complete initialization on the "Event Alert" page).

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.267 |

This component expects the following provider aliases (see `versions.tf` and stack-level provider configuration):

- `alicloud.sls_project`: used to create SLS alerts and query alert resources. Region should be the same as the SLS project that stores ActionTrail logs.
- `alicloud.sls_resource_record`: used to create SLS users, user groups, and action policies. Region must be `cn-heyuan`.

## Resources

| Name | Type | Description |
|------|------|-------------|
| `alicloud_log_alert.*` | resource | SLS alerts for ActionTrail event templates |
| `alicloud_log_resource_record.user` | resource | SLS user resource records for alert recipients |
| `alicloud_log_resource_record.user_group` | resource | SLS user group resource records |
| `alicloud_log_resource_record.action_policy` | resource | SLS action policy that defines alert delivery behavior |
| `alicloud_log_alert_resource.init` | data source | Alert resource metadata (used to initialize built-in templates) |

## Usage

```hcl
module "event_alert" {
  source = "./components/log-archive/event-alert"

  providers = {
    alicloud.sls_project        = alicloud.sls_project
    alicloud.sls_resource_record = alicloud.sls_resource_record
  }

  project_name  = "actiontrail-log-project"
  logstore_name = "actiontrail_logstore"
  lang          = "en-US"

  users = [
    {
      id    = "user.example"
      name  = "Example User"
      email = ["user@example.com"]
      phone = "18888888888"
    }
  ]

  user_groups = [
    {
      id            = "group_example"
      name          = "Example Group"
      user_ids      = ["user.example"]
      use_all_users = false
    }
  ]

  use_existing_action_policy = false
  action_policy_id           = "policy_example"
  action_policy_name         = "example_policy"

  action_policy_scripts = [
    {
      type        = "email"
      users       = []
      groups      = ["group_example"]
      template_id = null
      period      = "any"
    }
  ]

  enabled_alerts = [
    "cis.at.abnormal_login",
    "cis.at.root_login",
    "ip_insight_v2",
    "cis.at.vpc_flowlog_off"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enabled_alerts` | Alert identifiers to enable | `list(string)` | `[]` | No | Values must match supported alerts (see Alerts List) |
| `project_name` | SLS project that stores ActionTrail logs | `string` | - | Yes | 3-63 chars, start/end with lowercase letter or digit, only lowercase letters, digits, and hyphens (-) |
| `logstore_name` | Logstore in the project used to store ActionTrail events | `string` | - | Yes | 2-63 chars, start/end with lowercase letter or digit, only lowercase letters, digits, hyphens (-), and underscores (_) |
| `lang` | Language for alert templates and display names | `string` | `"zh-CN"` | No | Typically `zh-CN` or `en-US` |
| `users` | Users to receive alert notifications | `list(object)` | `[]` | No | See users object structure |
| `user_groups` | SLS user groups that receive alerts, optionally with explicit member `user_ids` | `list(object)` | `[]` | No | See user_groups object structure |
| `use_existing_action_policy` | Whether to use an existing SLS action policy instead of creating a new one | `bool` | `false` | No | When `true`, only `action_policy_id` is required and action policy resource is not created |
| `action_policy_id` | ID of the SLS action policy | `string` | - | Yes | 5-60 chars, start with letter, only letters, digits, underscores, hyphens, and periods |
| `action_policy_name` | Display name of the SLS action policy | `string` | `null` | No | When set: 1-40 chars, cannot contain `\ $ \| ~ ? & < > { } \` ' "` |
| `action_policy_scripts` | Optional action scripts (`fire(...)` statements) for the alert policy | `list(object)` | `[]` | No | See action_policy_scripts object structure |

### Users Object Structure

Each element in `users` has the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `string` | Yes | User ID, used as SLS user_id; 5-60 chars, start with letter, only letters, digits, underscores, hyphens, and periods |
| `name` | `string` | Yes | Display name; 1-20 chars, cannot contain `\ $ \| ~ ? & < > { } \` ' "` |
| `sms_enabled` | `bool` | No | Whether SMS notifications are enabled; default `true` |
| `phone` | `string` | No | Phone number, up to 20 digits, numeric only |
| `voice_enabled` | `bool` | No | Whether voice notifications are enabled; default `true` |
| `email` | `list(string)` | No | Email addresses for the user |
| `enabled` | `bool` | No | Whether the user is enabled; default `true` |
| `country_code` | `string` | No | Country code for phone number (e.g. `"86"`) |

Each user must have at least one contact channel: either a non-empty `phone` or a non-empty `email` list. When `phone` is set, `country_code` must also be set.

### User Groups Object Structure

Each element in `user_groups` has the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `string` | Yes | User group ID; 5-60 chars, start with letter, only letters, digits, underscores, hyphens, and periods |
| `name` | `string` | Yes | User group display name; 1-20 chars, cannot contain `\ $ \| ~ ? & < > { } \` ' "` |
| `user_ids` | `list(string)` | No | Explicit list of member user IDs; defaults to `[]` |
| `use_all_users` | `bool` | No | When `true`, group members are all user IDs from `users`; when `false`, members are `user_ids` only |

### Action Policy Scripts Object Structure

Each element in `action_policy_scripts` represents one `fire(...)` statement:

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `type` | `string` | - | Yes | Alert action type; must be one of: `sms`, `voice`, `email` |
| `users` | `list(string)` | `[]` | No | User IDs to notify directly |
| `groups` | `list(string)` | `[]` | No | User group IDs to notify |
| `template_id` | `string` | `null` | No | SLS alert template ID; when null, a built-in template is selected based on `lang` |
| `period` | `string` | `"any"` | No | When alert notifications can be sent; must be one of: `any`, `workday`, `non_workday`, `worktime`, `non_worktime` |

If `action_policy_scripts` is empty, no `primary_policy_script` is generated and the module does not control how alerts are delivered.

## Alerts List

| Alert | Alert Name | Description |
| --- | --- | --- |
| cis.at.abnormal_login | Account Continuous Login Failure Alert | Check every 15 minutes. The alert will be triggered if the number of failed logins is too many within 30 minutes. The trigger threshold can be configured in the rule parameters, and the default is 5 times. |
| cis.at.root_login | Alert for Continuous Login of Root Account | Root users should not login too frequently. Check every 15 minutes, the trigger condition is: root account has more than 5 times of login (configurable in rule parameters) within 30 minutes. |
| cis.at.ram_mfa_login | Alert of RAM User Login without MFA | Check every 15 minutes and scan logs in the past 30 minutes. When there exist logs of RAM user logins without MFA check, an alert will be triggered. |
| cis.at.unauth_login | Unauthorized IP Login Alert | Check every 15 minutes, and check the log of the past 30 minutes. IP login outside the scope of white list triggers alert |
| cis.at.off_duty_login | Alert of Login During Non-working Time | Check every 1 minutes, and the trigger condition is: during the past 1 minutes, there is a non-working time login behavior. Working time/non-working time range can be set in the Global Calendar component. |
| cis.at.abnormal_ak_usage | Alert of Frequency of AK Abnormal Usage | Check every 15 minutes. In the past 30 minutes, if the abnormal frequency of using AK exceeds the specified threshold, the alert will be triggered. The trigger threshold can be configured in rule parameters. |
| cis.at.ak_conf_change | KMS Key Configuration Change Alert | Check every 15 minutes, and the trigger condition is: in the past 30 minutes, there exists an operation of changing the KMS key configuration (such as deleting or disabling, etc.). |
| cis.at.root_ak_usage | Root Account AK Usage Detection | Check every 15 minutes, the trigger condition is that there is a usage record of Root account AK in the past 30 minutes.The Root account should not create and use the Access Key, otherwise an alert will be triggered. |
| cis.at.ram_auth_change | Alert of RAM Auth Change | Check every 15 minutes and scan logs in the past 30 minutes. When there exit logs of RAM auth change, an alert will be triggered. |
| cis.at.ram_policy_change | RAM policy Change Alert | Check every 15 minutes, check the log of the past 30 minutes. Alerts are triggered when the RAM policy changes. |
| cis.at.pwd_login_attemp_policy | Alert of Abnoraml Settings for RAM Password Login Retry Policy | According to Alibaba Cloud CIS rules, in RAM password login retry policy, the number of login attempts with wrong password within one hour cannot be more than 5 times (the threshold can be configured in the parameters of alert rule). This rule is checked every 15 minutes, and the trigger condition is: in the past 30 minutes, some operations have set the non-compliant RAM password login retry policy. |
| cis.at.pwd_expire_policy | Alert of Abnormal Setting of RAM Password Expire Policy | According to Alibaba Cloud CIS rules, in RAM password policy, the validity period of RAM password should be set to 90 days or less (configurable in the parameter of alert rule). This rule is checked every 15 minutes, and the trigger condition is: in the past 30 minutes, some actions have set too long password validity period in RAM password policy. |
| cis.at.pwd_reuse_prevention_policy | Alert of Setting of RAM Historical Passwords Check Policy | In the RAM history password check policy, it is forbidden to use the previous N passwords. The minimum value of n can be configured in the parameters of alert rules. If the value is less than this value, the alert will be triggered. This rule is checked every 15 minutes, and check the log of the past 30 minutes. |
| cis.at.pwd_length_policy | Alert of Abnormal Setting of RAM Password Length Policy | In the RAM password policy, the minimum length of RAM password cannot be less than 14 (which can be configured in the alert rule parameters), otherwise an alert will be triggered. This rule is checked every 15 minutes to check the log of the past 30 minutes. |
| cis.at.abnormal_pwd_mod_cnt | Alert of Abnormal Password Modification Frequency | Checking every 15 minutes. The trigger condition is that the number of password modification operations exceeds the specified threshold in the past half hour (the default threshold is 1), which can be configured in the rule parameters. |
| cis.at.password_reset | Alert of Password Reset Event | Check every 15 minutes, the trigger condition is that there is a password reset event in the past 30 minutes. |
| cis.at.password_change | Alert of Attempt to Modify Password Policy | Check every 15 minutes, the trigger condition is: in the past 30 minutes, there has been an operation to try to modify the password policy. |
| ip_insight | IpInsight Alert(Old Version) | Check at every 15 minutes, trigger condition is: there exists events of IpInsight in the past 30 minutes. Only valid for old version Insights. |
| ip_insight_v2 | IpInsight Alert(New Version) | Check at every 15 minutes, trigger condition is: there exists events of IpInsight in the past 30 minutes. Only valid for new version Insights. |
| cis.at.trail_off | Alert of Attempt to Turn off Trails | Check every 15 minutes, and the trigger condition is that there is an attempt to turn off trails in the past 30 minutes. |
| cis.at.ecs_force_reboot | Alert of ECS Instance Forced Reboot | After the ECS instance is forcibly rebooted, an alert is triggered. Check at every 15 minutes, the trigger condition is: in the past 30 minutes, there is an event of forced reboot of ECS instance. |
| cis.at.ecs_reboot_alot | Excessive Restart of ECS instance | Check every 15 minutes, the trigger condition is that the ECS instance has been restarted too many times in the past 30 minutes. The trigger threshold can be configured in rule parameters. |
| cis.at.esc_release | ECS Instance released Alert | Check every 15 minutes, the trigger condition is that there was an event that ECS instance was released in the past 30 minutes. |
| cis.at.ecs_disk_release | ECS Cloud Disk Released Alert | Check every 15 minutes, the trigger condition is: the ECS cloud disk was released in the past 30 minutes. |
| cis.at.ecs_release_protec_off | Alert of ECS Instance Release Protection Close | Check every 15 minutes, the trigger condition is: in the past 30 minutes, there is an operation to close the ECS instance release protection. |
| cis.at.ecs_disk_reinit | ECS Cloud Disk Reinit Alert | Check every 15 minutes, the trigger condition is that there is an ECS cloud disk reinitialization event in the past 30 minutes. |
| cis.at.ecs_auto_snapshot_policy | ECS Automatic Snapshot Policy Shutdown Alert | Check every 15 minutes, the trigger condition is that there was an operation to close the ECS automatic snapshot policy in the past 30 minutes. ECS disks are recommended to use the automatic snapshot policy for automatic backups. Turning off the automatic snapshot policy will trigger an alert. |
| cis.at.ecs_disk_encry_detc | Alert of ECS Cloud Disk Encryption Not Enabled | When creating ECS cloud disk, you should enable disk encryption, otherwise an alert will be triggered. Check every 15 minutes, the trigger condition is: in the past 30 minutes, an ECS cloud disk has been created without enabling encryption. |
| cis.at.securitygroup_change | Security Group Configurations Change alert | Check every 15 minutes, the trigger condition is that there is an event of security group configuration change in the past 30 minutes. |
| db.at.rds_instance_del | RDS Instance Released Alert | Check every 15 minutes, the trigger condition is: there exist RDS instance release events in the past 30 minutes. |
| cis.at.rds_access_whitelist | Alert of Abnormal Setting for RDS Instance Access Whitelist | The access whitelist of RDS instance should not be set to 0.0.0.0, otherwise an alert will be triggered. It is checked every 15 minutes, and the trigger condition is: in the past 30 minutes, there is an RDS instance whitelist setting operation related to the above abnormality. |
| cis.at.rds_sql_audit | Alert of Turning off RDS SQL Insight | The SQL insight of RDS instance should remain on, the turning off of which will trigger an alert. Check at every 15 minutes, the trigger condition is: in the past 30 minutes, there is an operation to turn off RDS SQL insight. |
| cis.at.rds_ssl_config | Alert of Turning off RDS Instance SSL | SSL of RDS instance should remain on, the turning off of which will trigger an alert. Check at every 15 minutes, and the trigger condition is: in the past 30 minutes, there has been an operation to turn off the SSL of RDS instance. |
| cis.at.rds_conf_change | RDS instance Configurations Change Alert | Check every 15 minutes, the trigger condition is that there are RDS instance configuration change events in the past 30 minutes. |
| cis.at.oss_policy_change | OSS Bucket Policy Change Alert | Check every 15 minutes, the trigger condition is: in the past 30 minutes, there is an operation to change the permission of OSS Bucket. |
| cis.at.sas_webshell_unbind | SAS Webpage Anti-tampering Protection Unbinding Alert | The webpage anti-tampering of the Cloud Security Center(SAS) will trigger an alert after unbinding the protection of the server. Check at every 15 minutes, and check the events in the past 30 minutes. |
| cis.at.sas_webshell_detection | SAS Webpage Anti-tampering Protection Status Disabled Alert | The protection status of Cloud Security Center(SAS) webpage anti-tampering on your servers should be kept enabled, and an alert will be triggered when it is disabled. Check at every 15 minutes, and check the events in the past 30 minutes. |
| cis.at.vpc_flowlog_off | Alert of Abnormal Change of VPC Flowlog Configuration | All VPCs should open the flow log, and closing or deleting the flow log will trigger an alert. Check at every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.vpc_route_change | VPC Network Route Change Alert | Check every 15 minutes, the trigger condition is that there is a change event of VPC network route configuration in the past 30 minutes. |
| cis.at.vpc_conf_change | VPC Configuration Change Alert | Check every 15 minutes, the trigger condition is that there are VPC configuration change events in the past 30 minutes. |
| dataflow.at.slb_http | LoadBalancer(SLB) HTTP Access Protocol Enabled Alert | LoadBalancer(SLB) should disable access over the HTTP protocol and only allow access over the HTTPS protocol. Check every 15 minutes, the trigger condition is that there was an event to open the LoadBalancer HTTP access protocol in the past 30 minutes. |
| cis.at.api_err | Alert of Frequency of API Error | Check every 15 minutes, the trigger condition is that the number of API call errors in the past 30 minutes exceeds the specified threshold, which can be configured in the rule parameters. |
| cis.at.unauth_apicall | Alert for Unauthorized API calls | Check every 15 minutes, the trigger condition is that the number of unauthorized API calls within 30 minutes exceeds the specified threshold. The trigger threshold can be configured in rule parameters. |
| cis.at.cloudfirewall_conf_change | VPC Firewall Control Policy Change Alert | It is checked every 15 minutes, and the trigger condition is: in the past 30 minutes, there has been one or more changes in the control policy of VPC Firewall. |
| cis.at.cfw_basic_rule_off | Alert of Turning off of Cloudfirewall Basic Defense | After the basic defense rules of the cloudfirewall is turned off, an alert will be triggered. Check at every 15 minutes, and check the events of the past 30 minutes |
| cis.at.cfw_ai_off | Alert of Turning off of Cloudfirewall Intelligent Defense | After the intelligent defense of the cloudfirewall is turned off, an alert will be triggered. Check at every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_ti_off | Alert of Turning off of Cloudfirewall Threat Intelligence | After the threat intelligence of the cloudfirewall is turned off, an alert will be triggered. Check at every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_patch_off | Alert of Turning off of Cloudfirewall Virtual Patch | After the virtual patch of the cloudfirewall is turned off, an alert will be triggered. Check at every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_log_off | Alert of Turning off of Cloudfirewall Log Analysis | After the log analysis of the cloudfirewall is turned off, an alert will be triggered. Check at every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_obs_mode | Alert of Cloudfirewall Switched to Observation Mode | After the threat engine of the cloudfirewall is switched to the observation mode, an alert is triggered. Check every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_loose_block | Alert of Cloudfirewall Switched to Loose Interception Mode | After the threat engine of the cloudfirewall is switched to loose interception mode, an alert is triggered. Check every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_assets_protec_off | Alert of Turning off of Cloudfirewall Protection for Assets | An alert will be triggered when the cloudfirewall protection of specified asset is turned off. Check at every 15 minutes, and check the events of the past 30 minutes. |
| cis.at.cfw_assets_auto_protec_off | Alert of Disabled Auto Protection of New Assets in Cloudfirewall | After the automatic protection of new assets in cloudfirewall is turned off, an alert will be triggered. Check at every 15 minutes, and check the events of the past 30 minutes. |

## Authors

Created and maintained by Alibaba Cloud Landing Zone Team

## License

MIT License. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
