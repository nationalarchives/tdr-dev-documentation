# TDR Add Grafana User

Grafana currently, does not have an email server set up.

## Add New User Without Sending Email Via Grafana

As a temporary work around to add a new user without sending an email via Grafana, follow these instructions:

1. Log into Grafana as an admin user
2. Go to "Configuration" > "Users"
3. Click "Invite"
4. Fill in the relevant information for the new user in the form.
5. Ensure the "Send invite email" option is turned off in the form
6. Click "Submit"
7. On the "User" page click on the "Pending invites" tab
8. On the "Pending invites" tab, find the invite for the new user, and click on the "Copy invite" button for the new user:
   * This will copy the invite link
9. Paste the invite link to an email, and send the email to the new user.
