variable "enabled_alerts" {
  description = "Alert identifiers to enable (see README for supported values)."
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "SLS project that stores ActionTrail logs."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits and hyphens (-)."
  }
}

variable "logstore_name" {
  description = "Logstore in the project used to store ActionTrail events."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]{0,61}[a-z0-9]$", var.logstore_name))
    error_message = "logstore_name must be 2-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits, hyphens (-), and underscores (_)."
  }
}

variable "lang" {
  description = "Language for alert notifications (e.g. zh-CN, en-US)."
  type        = string
  default     = "zh-CN"
}

variable "users" {
  description = "Users to receive alert notifications (basic identity plus optional contact channels)."
  type = list(object({
    id            = string
    name          = string
    sms_enabled   = optional(bool, true)
    phone         = optional(string)
    voice_enabled = optional(bool, true)
    email         = optional(list(string))
    enabled       = optional(bool, true)
    country_code  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for u in var.users :
      length(u.id) >= 5 && length(u.id) <= 60 && can(regex("^[a-zA-Z][a-zA-Z0-9_.-]*$", u.id))
    ])
    error_message = "Each user id must be 5-60 characters, start with a letter, and contain only letters, digits, underscores, hyphens, and periods."
  }

  validation {
    condition = alltrue([
      for u in var.users :
      length(u.name) >= 1 && length(u.name) <= 20 && !can(regex("[\\\\$|~?&<>{}`'\"]", u.name))
    ])
    error_message = "Each user name must be 1-20 characters and cannot contain \\ $ | ~ ? & < > { } ` ' \"."
  }

  validation {
    condition = alltrue([
      for u in var.users :
      u.phone == null || can(regex("^[0-9]{1,20}$", u.phone))
    ])
    error_message = "If phone is set, it must be 1-20 digits and contain only numbers."
  }

  validation {
    condition = alltrue([
      for u in var.users :
      (u.phone != null && u.phone != "") || try(length(u.email), 0) > 0
    ])
    error_message = "Each user must have at least one contact: phone or email."
  }

  validation {
    condition = alltrue([
      for u in var.users :
      u.phone == null || u.phone == "" || (u.country_code != null && u.country_code != "")
    ])
    error_message = "If phone is set, country_code must also be set and non-empty."
  }
}

variable "user_groups" {
  description = "SLS user groups that receive alerts, optionally with explicit member user_ids."
  type = list(object({
    id            = string
    name          = string
    user_ids      = optional(list(string), [])
    use_all_users = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for g in var.user_groups :
      length(g.id) >= 5 && length(g.id) <= 60 && can(regex("^[a-zA-Z][a-zA-Z0-9_.-]*$", g.id))
    ])
    error_message = "Each user group id must be 5-60 characters, start with a letter, and contain only letters, digits, underscores, hyphens, and periods."
  }

  validation {
    condition = alltrue([
      for g in var.user_groups :
      length(g.name) >= 1 && length(g.name) <= 20 && !can(regex("[\\\\$|~?&<>{}`'\"]", g.name))
    ])
    error_message = "Each user group name must be 1-20 characters and cannot contain \\ $ | ~ ? & < > { } ` ' \"."
  }
}

variable "use_existing_action_policy" {
  description = "Whether to use an existing SLS action policy instead of creating a new one. When true, only action_policy_id is required and the action_policy resource will not be created."
  type        = bool
  default     = false
}

variable "action_policy_id" {
  description = "ID of the SLS action policy that defines how alerts are delivered."
  type        = string

  validation {
    condition     = length(var.action_policy_id) >= 5 && length(var.action_policy_id) <= 60 && can(regex("^[a-zA-Z][a-zA-Z0-9_.-]*$", var.action_policy_id))
    error_message = "action_policy_id must be 5-60 characters, start with a letter, and contain only letters, digits, underscores, hyphens, and periods."
  }
}

variable "action_policy_name" {
  description = "Display name of the SLS action policy."
  type        = string
  default     = null

  validation {
    condition = var.action_policy_name == null || (
      try(length(var.action_policy_name), 0) >= 1 &&
      try(length(var.action_policy_name), 0) <= 40 &&
      !can(regex("[\\\\$|~?&<>{}`'\"]", var.action_policy_name))
    )
    error_message = "When set, action_policy_name must be 1-40 characters and cannot contain \\ $ | ~ ? & < > { } ` ' \"."
  }
}

variable "action_policy_scripts" {
  description = "Optional action scripts (fire statements) for the alert policy."
  type = list(object({
    type        = string
    users       = optional(list(string), [])
    groups      = optional(list(string), [])
    template_id = optional(string)
    period      = optional(string, "any")
  }))
  default = []

  # type must be one of supported channels
  validation {
    condition = alltrue([
      for a in var.action_policy_scripts :
      contains(["sms", "voice", "email"], a.type)
    ])
    error_message = "Each action_policy_scripts.type must be one of: sms, voice, email."
  }

  # period must be one of supported values
  validation {
    condition = alltrue([
      for a in var.action_policy_scripts :
      contains(["any", "workday", "non_workday", "worktime", "non_worktime"], a.period)
    ])
    error_message = "Each action_policy_scripts.period must be one of: any, workday, non_workday, worktime, non_worktime."
  }
}
