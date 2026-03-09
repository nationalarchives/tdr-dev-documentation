# 39. Observability

**Date**: 2026-03-06

## Context
We wish to bolster our Observability capability, particularly for alarming/alerting.

Currently, we are using an AWS Managed Grafana instance.  This has a handful of dashboards and alerts, but has never really gained traction in the team and has little use.  We do not use it for reading logs.  Everything is hand-cranked, save for the installation of the service.  Logs are generally sent to Cloudwatch.

We would like to:

* Have a single tool for observability

* Have a solution that makes it easy to generate alarms in Terraform

* Have a solution that makes it easy to generate alerts that are sent to slack in Terraform

# Decision

We will implement the observability/alarming solution that was used in [DDT ADR-011](https://national-archives.atlassian.net/wiki/spaces/DDT/pages/411926532/ADR-011+Observability+-+Alerting+Infrastructure) which in a nutshell:

* Creates a Eventbridge Event bus in the management account receiving alarm events from other accounts

* Creates a rule on the default Eventbridge Event bus for all accounts, which forwards all ```CloudWatch Alarm State Change``` to the alarms bus in the management account

* Create rules on the alarms bus e.g. to send certain alarms to Slack etc

* Create alarms in Terraform

We will evaluate the existing dashboards and alarms in the existing Grafana instance and move them to Cloudwatch.

We will terminate our managed Grafana instance.

# Consequences

We will implement DDT ADR-011.

We will define alarms and implement them.  We will use the [AWS Recommended alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Best_Practice_Recommended_Alarms_AWS_Services.html) as a starting point.

We will setup up [CloudWatch cross-account observability](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Unified-Cross-Account.html).

We need to work out a pattern for how alarms should be created.  They need to be created in the management account.  Likely with a provider to the management account in the tdr-terraform-environments stack.

