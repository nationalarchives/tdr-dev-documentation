#Accessing an environment's database

Connecting to a database must be done through an AWS Bastion host, below are the steps detailing how to do this

##1. Downloading and installing the Session Manager plugin
First you need to download and install the AWS Session Manager plugin

   * [Instructions for Mac (Step 1 to 3)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos)
   * [Instructions for Ubuntu (Step 1 to 2)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-debian)
   * [Instructions for Amazon Linux (Step 1 to 2)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux)

You can check if it worked by running `session-manager-plugin`, which should show you the message

`The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.`

##2. Obtaining the Instance ID for the Bastion instance

Next, you need to get the instance id for the bastion instance which can be found via command line or through the AWS console.

###Via Command line (after you've updated your credentials)

   Run this `aws ec2 describe-instances --profile <profile name>`
   (replacing the angle bracket parameter, with the name of your profile; if you are not sure or if it's failing, omit the `--profile <profile name>` part before running and see if it works)

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
- Find the bastion ec2 instance, for e.g "bastion-ec2-instance-intg" for the intg environment
- Copy the "Instance ID"

##3. Connecting via Session Manager
Now you need to connect via the session manager by running the command

   `aws ssm start-session --target <the InstanceId you've copied> --profile <profile name>`
   (replacing the angle-bracket parameter, with the name of your profile; if you are not sure or if it's failing, omit the `--profile <profile name>` part before running and see if it works)

##4. Starting PSQL

Step 3 should bring up a prompt that looks something like this:
```
Starting session with SessionId: <SessionId>
sh-4.2
```

* if you are connecting to an **existing** Bastion, press the up arrow key on your keyboard once or twice (to cycle through the history), you should see a psql command

`psql -h <db url> -U <username> -d consignmentapi`

If not, you can enter this command manually, replacing the angle bracket parameters (above) with the actual values that you can retrieve via a CLI command or find on the AWS Parameter Store

###How to retrieve the values via CLI

After updating the credentials for the environment you are interested in, just run this command replacing the parameter angle bracket parameter, with the environment, you are interested in, e.g. intg

`aws ssm get-parameters --names "/<env>/consignmentapi/database/url" "/<env>/consignmentapi/database/username" --with-decryption`

This should print a JSON with two objects inside; the "Value" key of each will have the values for the PSQL command

```
{
    "Parameters": [
        {
            "Name": "/<env>/consignmentapi/database/url",
            "Value": "<db url>",
            ...etc
        },
        {
            "Name": "/<env>/consignmentapi/database/username",
            "Value": "<username>",
            ...etc
        }

```

###How to find the values on the Parameter Store

- In the AWS console:
  - Navigate to the Parameter Store (type it in the search bar) to see the list of parameters
  - Find the database url parameter, e.g. `/intg/consignmentapi/database/url`
  - Copy the parameter's value
  - This will replace the "db url" angle bracket parameter in the psql command
  - Go back to the list of parameters and find the username parameter, e.g. `/intg/consignmentapi/database/username`
  - Copy the parameter's value
  - This will replace the "username" angle bracket parameter in the psql command
 
After running this command, you should be inside of psql.
