## March 23, 2026

- **New Component under** `components/log-archive`: `event-alert` — SLS ActionTrail event alerts (alert rules, notification users and groups, action policies).

## February 11, 2026

- **New Components under** `components/network`: `cen-instance`, `cen-transit-router`, `cen-route-map`, `cen-tr-inter-region-connection`, and `cen-vpn-connection` — CEN networking split from the previous single `network/cen` layout.
- **New Components under** `components/account-factory/baseline`: `contact`, `preset-tag`, `ram-role`, `ram-security-preference`, `ram-user`, `security-group`, and `vpc-baseline` — baseline decomposed into dedicated subcomponents.
- **New Modules under** `modules`: `cen-bandwidth-package`, `common-bandwidth-package`, `security-group`, and `tag-policy`.
- **New Modules under** `modules`: `cms-service` and `cms-alarm-contact` — replaces the earlier consolidated `cms` module.

ENHANCEMENTS:

- **component/security:** Expanded `cloud-firewall`, `bastion-host`, `wafv3`, and `kms` configurations and inputs (including additional policy and control-plane YAML/JSON support).
- **component/account-factory:** Updated `account` component alongside the baseline refactor.

## January 4, 2026

- **Project initialization:** Add the first set of core **components** (account factory, guardrails, identity, log archive, network, resource structure, security) and supporting **modules** (network, logging, OSS/SLS, CloudSSO, Config recorder, contact, RAM, KMS, etc.).
