# Missed Jenkins backups

We use [healthchecks.io] to monitor for missing Jenkins backups. If a backup
doesn't run, you will see a Slack message like this in the da-tdr channel:

```
“Jenkins backup” is DOWN.
Project    Schedule
TDR        0 18 ͏* ͏* 1-5

Last Ping  Total Pings
1 day ago  37
```

To investigate why the backup didn't run, check the [Maintenance Window history]
in the TDR Management AWS account.

To manually initiate a backup, follow the [instructions in the Jenkins
Readme][backup-guide].

[healthchecks.io]: https://healthchecks.io/
[Maintenance Window history]: https://eu-west-2.console.aws.amazon.com/systems-manager/maintenance-windows/mw-0bd9ef68cfe04bd4e/history?region=eu-west-2
[backup-guide]: https://github.com/nationalarchives/tdr-jenkins#backups
