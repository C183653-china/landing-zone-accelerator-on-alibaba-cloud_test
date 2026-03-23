## Event Alert 组件

该组件基于阿里云 ActionTrail 事件模板，在 SLS 中创建和管理事件告警，包括用户、用户组和告警策略（Action Policy）。

### 功能特性

- 创建 SLS 资源记录用于表示告警用户和用户组
- 创建 SLS Action Policy，用于控制告警通知的发送方式（邮件 / 短信 / 语音）
- 为丰富的 ActionTrail 安全与合规规则创建 SLS 告警
- 支持多个用户组以及每个用户组独立的成员配置
- 支持复用已有 Action Policy，或由模块新建 Action Policy

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | ~> 1.267 |

> **重要说明：** 如果需要在**操作审计控制台看到告警**，需要在操作审计控制台**手动开启事件告警功能**（例如在「事件告警」页面完成初始化开通）。

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.267 |

本组件期望以下 Provider 别名（详见 `versions.tf` 以及 Stack 级 Provider 配置）：

- `alicloud.sls_project`：用于创建 SLS 告警和查询告警资源。Region 应与存放 ActionTrail 日志的 SLS Project 保持一致。
- `alicloud.sls_resource_record`：用于创建 SLS 用户、用户组和 Action Policy。Region 必须为 `cn-heyuan`。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| `alicloud_log_alert.*` | resource | 各类基于 ActionTrail 的 SLS 告警 |
| `alicloud_log_resource_record.user` | resource | 告警用户的 SLS 资源记录 |
| `alicloud_log_resource_record.user_group` | resource | 告警用户组的 SLS 资源记录 |
| `alicloud_log_resource_record.action_policy` | resource | 定义告警发送行为的 SLS Action Policy |
| `alicloud_log_alert_resource.init` | data source | 告警资源元数据（用于初始化内置模板） |

## 使用示例

```hcl
module "event_alert" {
  source = "./components/log-archive/event-alert"

  providers = {
    alicloud.sls_project         = alicloud.sls_project
    alicloud.sls_resource_record = alicloud.sls_resource_record
  }

  project_name  = "actiontrail-log-project"
  logstore_name = "actiontrail_logstore"
  lang          = "zh-CN"

  users = [
    {
      id    = "user.example"
      name  = "示例用户"
      email = ["user@example.com"]
      phone = "18888888888"
    }
  ]

  user_groups = [
    {
      id            = "group_example"
      name          = "示例用户组"
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

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enabled_alerts` | 需要启用的告警标识列表 | `list(string)` | `[]` | No | 取值必须在支持的告警列表中（见 Alerts List） |
| `project_name` | 存放 ActionTrail 日志的 SLS 项目名称 | `string` | - | Yes | 3-63 个字符，以小写字母或数字开头和结尾，只能包含小写字母、数字和短横线 (-) |
| `logstore_name` | 存放 ActionTrail 日志的日志库名称 | `string` | - | Yes | 2-63 个字符，以小写字母或数字开头和结尾，只能包含小写字母、数字、短横线 (-) 和下划线 (_) |
| `lang` | 告警模板与显示名称的语言 | `string` | `"zh-CN"` | No | 一般为 `zh-CN` 或 `en-US` |
| `users` | 接收告警通知的用户列表 | `list(object)` | `[]` | No | 见 Users 对象结构 |
| `user_groups` | 接收告警的 SLS 用户组列表，可选单独配置成员 `user_ids` | `list(object)` | `[]` | No | 见 User Groups 对象结构 |
| `use_existing_action_policy` | 是否复用已有的 SLS Action Policy，而不由模块创建 | `bool` | `false` | No | 当为 `true` 时只需提供 `action_policy_id`，模块不会创建新的 Action Policy |
| `action_policy_id` | SLS Action Policy 的 ID | `string` | - | Yes | 5-60 个字符，以字母开头，仅包含字母、数字、下划线、短横线和点 |
| `action_policy_name` | SLS Action Policy 的显示名称 | `string` | `null` | No | 设置时需为 1-40 个字符，且不能包含 `\ $ \| ~ ? & < > { } \` ' "` 等特殊字符 |
| `action_policy_scripts` | 可选的告警行为脚本（`fire(...)` 语句）列表 | `list(object)` | `[]` | No | 见 Action Policy Scripts 对象结构 |

### Users 对象结构

`users` 中每个元素具有以下结构：

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `string` | Yes | 用户 ID，用作 SLS `user_id`；5-60 个字符，以字母开头，仅包含字母、数字、下划线、短横线和点 |
| `name` | `string` | Yes | 用户显示名称；1-20 个字符，且不能包含 `\ $ \| ~ ? & < > { } \` ' "` 等特殊字符 |
| `sms_enabled` | `bool` | No | 是否启用短信通知，默认 `true` |
| `phone` | `string` | No | 手机号码，最长 20 位纯数字 |
| `voice_enabled` | `bool` | No | 是否启用语音通知，默认 `true` |
| `email` | `list(string)` | No | 用户电子邮箱列表 |
| `enabled` | `bool` | No | 是否启用该用户，默认 `true` |
| `country_code` | `string` | No | 手机号国家码，例如 `"86"` |

每个用户必须至少配置一种联系方式：非空 `phone` 或非空 `email` 列表。若填写了 `phone`，则必须同时填写 `country_code`。

### User Groups 对象结构

`user_groups` 中每个元素具有以下结构：

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `string` | Yes | 用户组 ID；5-60 个字符，以字母开头，仅包含字母、数字、下划线、短横线和点 |
| `name` | `string` | Yes | 用户组显示名称；1-20 个字符，且不能包含 `\ $ \| ~ ? & < > { } \` ' "` 等特殊字符 |
| `user_ids` | `list(string)` | No | 该组的显式成员用户 ID 列表，默认 `[]` |
| `use_all_users` | `bool` | No | 为 `true` 时，该组成员为所有 `users` 中的 `id`；为 `false` 时仅使用 `user_ids` |

### Action Policy Scripts 对象结构

`action_policy_scripts` 中每个元素表示一条 `fire(...)` 语句：

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `type` | `string` | - | Yes | 告警行为类型；必须为：`sms`、`voice` 或 `email` |
| `users` | `list(string)` | `[]` | No | 直接通知的用户 ID 列表 |
| `groups` | `list(string)` | `[]` | No | 通知的用户组 ID 列表 |
| `template_id` | `string` | `null` | No | SLS 告警模板 ID；为空时根据 `lang` 自动选择内置模板 |
| `period` | `string` | `"any"` | No | 告警发送时间窗口；必须为：`any`、`workday`、`non_workday`、`worktime`、`non_worktime` 之一 |

当 `action_policy_scripts` 为空时，不会为 Action Policy 生成 `primary_policy_script`，模块也就不控制告警通知的发送逻辑。

## Alerts List

> 以下为内置告警模板列表及含义：

| Alert | Alert Name | Description |
| --- | --- | --- |
| cis.at.abnormal_login | 账号连续登录失败告警 | 每 15 分钟检查一次，在过去 30 分钟内如果登录失败次数超过阈值（可在规则参数中配置，默认 5 次）则触发告警。 |
| cis.at.root_login | Root用户控制台登录次数控制 | 每 15 分钟检查一次，在过去 30 分钟内若 Root 账号登录次数超过阈值（可在规则参数中配置，默认 5 次）则触发告警，Root 账号不应频繁登录。 |
| cis.at.ram_mfa_login | RAM子账号无MFA登录告警 | 每 15 分钟检查一次，扫描过去 30 分钟日志，如发现 RAM 用户未开启 MFA 的登录行为则触发告警。 |
| cis.at.unauth_login | 未授权的IP登录告警 | 每 15 分钟检查一次，扫描过去 30 分钟日志，如存在来自白名单范围外 IP 的登录行为，则触发未授权 IP 登录告警。 |
| cis.at.off_duty_login | 非工作时间登陆告警 | 每 1 分钟检查一次，在过去 1 分钟内如出现非工作时间的登录行为则触发告警；工作时间/非工作时间范围在全局日历组件中配置。 |
| cis.at.abnormal_ak_usage | AK使用的异常频率告警 | 每 15 分钟检查一次，在过去 30 分钟内若 AK 使用频率超过指定阈值（可在规则参数中配置）则触发告警。 |
| cis.at.ak_conf_change | KMS密钥配置变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在变更 KMS 密钥配置（如删除、禁用等）的操作则触发告警。 |
| cis.at.root_ak_usage | Root AK使用检测 | 每 15 分钟检查一次，在过去 30 分钟内如检测到 Root 账号 AK 的使用记录则触发告警；Root 账号不应创建和使用 AccessKey。 |
| cis.at.ram_auth_change | RAM权限变更告警 | 每 15 分钟检查一次，扫描过去 30 分钟日志，如存在 RAM 权限变更日志则触发告警。 |
| cis.at.ram_policy_change | RAM策略变更告警 | 每 15 分钟检查一次，扫描过去 30 分钟日志，如检测到 RAM 策略发生变更则触发告警。 |
| cis.at.pwd_login_attemp_policy | RAM密码登录重试策略异常设置告警 | 每 15 分钟检查一次，按照 CIS 规范，RAM 密码登录重试策略中 1 小时内错误密码登录次数不得超过 5 次（阈值可在规则参数中配置）；过去 30 分钟内如检测到将策略设置为不合规值则触发告警。 |
| cis.at.pwd_expire_policy | RAM密码过期策略异常设置告警 | 每 15 分钟检查一次，按照 CIS 规范，RAM 密码有效期应不大于 90 天（可在规则参数中配置）；过去 30 分钟内如检测到将密码有效期设置过长则触发告警。 |
| cis.at.pwd_reuse_prevention_policy | RAM历史密码检查策略异常设置告警 | 每 15 分钟检查一次，在 RAM 历史密码检查策略中要求禁止使用最近 N 个历史密码，若配置的 N 小于规则参数中的最小值，则在过去 30 分钟内出现该操作时触发告警。 |
| cis.at.pwd_length_policy | RAM密码长度策略异常设置告警 | 每 15 分钟检查一次，按照 CIS 规范，RAM 密码最小长度不得小于 14 位（可在规则参数中配置）；过去 30 分钟内如检测到将长度设置为不合规值则触发告警。 |
| cis.at.abnormal_pwd_mod_cnt | 密码修改操作频率异常告警 | 每 15 分钟检查一次，在过去 30 分钟内如密码修改操作次数超过指定阈值（默认 1 次，可在规则参数中配置）则触发告警。 |
| cis.at.password_reset | 密码重置事件的发生告警 | 每 15 分钟检查一次，在过去 30 分钟内如发生密码重置事件则触发告警。 |
| cis.at.password_change | 尝试修改密码策略的事件告警 | 每 15 分钟检查一次，在过去 30 分钟内如有尝试修改密码策略的操作则触发告警。 |
| ip_insight | IpInsight告警 | 每 15 分钟检查一次，若过去 30 分钟内存在 IpInsight 事件则触发告警，仅对旧版 IpInsight 生效。 |
| ip_insight_v2 | IpInsight告警 | 每 15 分钟检查一次，若过去 30 分钟内存在 IpInsight 事件则触发告警，仅对新版 IpInsight 生效。 |
| cis.at.trail_off | 尝试关闭跟踪的操作告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在尝试关闭 ActionTrail 跟踪的操作则触发告警。 |
| cis.at.ecs_force_reboot | ECS实例强制重启告警 | 每 15 分钟检查一次，在过去 30 分钟内如发生 ECS 实例被强制重启事件则触发告警。 |
| cis.at.ecs_reboot_alot | ECS实例重启次数过多告警 | 每 15 分钟检查一次，在过去 30 分钟内如某 ECS 实例重启次数过多且超过规则参数中配置的阈值则触发告警。 |
| cis.at.esc_release | ECS实例释放告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 ECS 实例被释放事件则触发告警。 |
| cis.at.ecs_disk_release | ECS云盘释放告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 ECS 云盘被释放事件则触发告警。 |
| cis.at.ecs_release_protec_off | ECS实例释放保护关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在关闭 ECS 实例释放保护的操作则触发告警。 |
| cis.at.ecs_disk_reinit | ECS云盘重新初始化告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 ECS 云盘重新初始化事件则触发告警。 |
| cis.at.ecs_auto_snapshot_policy | ECS自动快照策略关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在关闭 ECS 自动快照策略的操作则触发告警；建议为 ECS 云盘开启自动快照进行备份。 |
| cis.at.ecs_disk_encry_detc | ECS云盘加密未开启告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到创建的 ECS 云盘未开启加密则触发告警。 |
| cis.at.securitygroup_change | 安全组配置变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在安全组配置变更事件则触发告警。 |
| db.at.rds_instance_del | RDS实例释放告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 RDS 实例释放事件则触发告警。 |
| cis.at.rds_access_whitelist | RDS实例访问白名单异常设置告警 | 每 15 分钟检查一次，RDS 实例访问白名单不应设置为 0.0.0.0；在过去 30 分钟内如检测到此类不安全白名单配置操作则触发告警。 |
| cis.at.rds_sql_audit | RDS实例SQL洞察关闭告警 | 每 15 分钟检查一次，RDS 实例应保持 SQL 洞察开启；在过去 30 分钟内如检测到关闭 SQL 洞察的操作则触发告警。 |
| cis.at.rds_ssl_config | RDS实例SSL关闭告警 | 每 15 分钟检查一次，RDS 实例应保持 SSL 开启；在过去 30 分钟内如检测到关闭 SSL 的操作则触发告警。 |
| cis.at.rds_conf_change | RDS实例配置变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 RDS 实例配置变更事件则触发告警。 |
| cis.at.oss_policy_change | OSS Bucket权限变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在变更 OSS Bucket 权限的操作则触发告警。 |
| cis.at.sas_webshell_unbind | 云安全中心网页防篡改防护解绑告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在云安全中心网页防篡改从服务器解绑的事件则触发告警。 |
| cis.at.sas_webshell_detection | 云安全中心网页防篡改防护关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到云安全中心网页防篡改保护被关闭则触发告警。 |
| cis.at.vpc_flowlog_off | VPC流日志配置异常变更告警 | 每 15 分钟检查一次，所有 VPC 建议开启流日志；在过去 30 分钟内如检测到关闭或删除 VPC 流日志的操作则触发告警。 |
| cis.at.vpc_route_change | VPC网络路由变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 VPC 网络路由配置变更事件则触发告警。 |
| cis.at.vpc_conf_change | VPC通用配置变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 VPC 通用配置变更事件则触发告警。 |
| dataflow.at.slb_http | 负载均衡HTTP访问协议开启告警 | 每 15 分钟检查一次，负载均衡（SLB）应禁用 HTTP 协议，仅允许 HTTPS；在过去 30 分钟内如存在开启 SLB HTTP 访问协议的事件则触发告警。 |
| cis.at.api_err | API错误频率告警 | 每 15 分钟检查一次，在过去 30 分钟内如 API 调用错误次数超过规则参数配置的阈值则触发告警。 |
| cis.at.unauth_apicall | 未授权的API调用告警 | 每 15 分钟检查一次，在过去 30 分钟内如未授权 API 调用次数超过规则参数配置的阈值则触发告警。 |
| cis.at.cloudfirewall_conf_change | VPC边界防火墙控制策略变更告警 | 每 15 分钟检查一次，在过去 30 分钟内如存在 VPC 边界防火墙控制策略的变更操作则触发告警。 |
| cis.at.cfw_basic_rule_off | 云防火墙基础防御关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到关闭云防火墙基础防御规则的操作则触发告警。 |
| cis.at.cfw_ai_off | 云防火墙智能防御关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到关闭云防火墙智能防御的操作则触发告警。 |
| cis.at.cfw_ti_off | 云防火墙威胁情报关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到关闭云防火墙威胁情报的操作则触发告警。 |
| cis.at.cfw_patch_off | 云防火墙虚拟补丁关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到关闭云防火墙虚拟补丁的操作则触发告警。 |
| cis.at.cfw_log_off | 云防火墙日志分析功能关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到关闭云防火墙日志分析功能的操作则触发告警。 |
| cis.at.cfw_obs_mode | 云防火墙威胁引擎切换至观察模式告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到云防火墙威胁引擎切换为观察模式则触发告警。 |
| cis.at.cfw_loose_block | 云防火墙威胁引擎切换至宽松拦截模式告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到云防火墙威胁引擎切换为宽松拦截模式则触发告警。 |
| cis.at.cfw_assets_protec_off | 资产的云防火墙防护关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到指定资产的云防火墙防护被关闭则触发告警。 |
| cis.at.cfw_assets_auto_protec_off | 云防火墙新增资产自动保护关闭告警 | 每 15 分钟检查一次，在过去 30 分钟内如检测到云防火墙新增资产自动保护被关闭则触发告警。 |

