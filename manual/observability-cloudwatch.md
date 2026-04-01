# Observability - Cloudwatch
In [ADR 39](https://github.com/nationalarchives/tdr-dev-documentation/blob/TDRD-1376/alarms_docs/architecture-decision-records/0039-observability.md) the use Cloudwatch as an observability product was prescribed.

This document provides some basic guidance for managing dashboards, alarms and alerts.

**All dashboards, alarms and Eventbridge rules are created in the management account**

# Dashboards
Dashboard are handcranked for now.  They are backed up manually [here](https://github.com/nationalarchives/tdr-configurations)

# Alarms
Alarms are created in the environments stack.

Use the `alarm_deployer` provider when creating alarms to create them in the management account.

Use the convention of creating alarms in a file named ```root_alarms_<AWS Namespace>.tf```.

Alarms must always match a metric's dimensions (metrics do not have an ARN).

Alarm names should match this naming convention: ```<metrics_name_space> <why (usually the metric name)> <resource_triggering_alert>```

This assumes that the resource contains an account identifier.  If not add one in the alarm name.
For example,
* ```AWS/S3 Object Put in tdr-upload-files-quarantine-staging``` - environment name is in the resource
* ```AWS/ApplicationELB High 4XX Count Environment=intg, LB=app/tdr-transfer-service-intg/1234``` - environment is added to name

Alarms can be in one of three states OK, ALARM, and INSUFFICIENT_DATA (missing data).

It is important to consider how missing data is treated for a metric, i.e. is it a bad thing and should trigger an alarm?
See [Configuring how CloudWatch alarms treat missing data](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html)


# Alerting 
Eventbridge rules for alerting are created in the backend stack.

Alarms are not attached to actions in this design.  Instead the Alarm state change events are caught by Eventbridge rules.

Currently, all alarms that transition to an ALARM state are sent to slack.

Some alarms that transistion back to an OK state are sent to slack.  A rule needs to be created for each scenario.
It is important to think about this.  E.g. A CPU spike triggers an ALARM state (Slack alert is sent) if it then falls back within the alarm threshold (transition to OK state) an alert should be sent to Slack 
and so a rule would need to be created for this in Eventbridge.

# Slack setup
Channel ids are kept in the tdr-condifurations repo.

The ```TDR Notifier App``` is attached to channels that wish to recieve messages.

Slack message templates are in the [backend stack](https://github.com/nationalarchives/tdr-terraform-backend/tree/master/templates/alarms).

The [Slack block kit](https://app.slack.com/block-kit-builder/) is a nice way to build templates.  Currently, we use a single template for OK and ALERT type messages.
