#Accessing the Integration database

Connecting to the Integration database must be done through an AWS Bastion host, below are the steps detailing how to do this

##1. Downloading and installing the Session Manager plugin
First you need to download and install the AWS Session Manager plugin

   * [Instructions for Mac (Step 1 to 3)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos)
   * [Instructions for Linux (Step 1 to 2)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux)
   * [Instructions for Ubuntu Server (Step 1 to 2)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-debian)

You can check if it worked by running  `session-manager-plugin`, which should show you the message

`The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.`

##2. Obtaining the Instance ID for the Bastion instance

Next, you need to get the instance id for the bastion instance which can be found via command line or through the AWS console.

###Via Command line (after you've updated your credentials)

   Run this `aws ec2 describe-instances --profile integration` (or whatever the name of your integration profile is; if you are not sure or it's failing, omit the `--profile integration` part before running and see if it works)

   It will print out a JSON like this:

       "Reservations": [
           {
               "Groups": [],
               "Instances": [
                   {
                       "AmiLaunchIndex": x,
                       "ImageId": "xxxxxxxx",
                       "InstanceId": "xxxxxxxxx",
       ...etc

Copy the value of the `InstanceId`

###Via Console

Alternatively, you can also get it from the console:

- In the search bar, type in "EC2" 
- Under "Resources", click "Instances"
- Find the "bastion-ec2-instance-intg" instance
- Copy the "Instance ID"

##3. Connecting via Session Manager
Now you need to connect via the session manager by running the command

   `ssm aws ssm start-session --target <the InstanceId you've copied> --profile integration`
   (or whatever the name of your Integration profile is; if you are not sure, or it's failing, omit the '--profile integration' and see if it works)

##4. Starting PSQL

Step 3 should bring up a prompt that looks something like this:
```
Starting session with SessionId: <SessionId>
sh-4.2
```

* if you press the up arrow key on your keyboard once or twice (to cycle through the history), you should see a psql command

`psql -h <db url> -U <username> -d consignmentapi`

If not, you can enter this command manually, replacing the parameters (in the angle brackets) with the actual values that you can find on the AWS Parameter Store

###How to find the values on the Parameter Store

- In the AWS console:
  - Navigate to the Parameter Store (type it in the search bar) to see the list of parameters
  - Find the `/intg/consignmentapi/database/url` parameter
  - Copy the parameter's value
  - This will replace the <db url> parameter in the psql command
  - Go back to the list of parameters and find the `/intg/consignmentapi/database/username` parameter
  - Copy the parameter's value
  - This will replace the <username> parameter in the psql command
 
After running this command, you should be inside of psql.
