# Accessing an environment's database

In order to connect to a database, it must be done through an AWS Bastion host, which must be deployed first;
[here](./applying-or-destroying-a-bastion-host.md) is how to do that.
Once you have done that, you can either access it directly via the AWS console or via your computer's CLI

## Accessing database via AWS console

* In the search bar, type in "EC2"
* Under "Resources", click "Instances"
* Find the bastion ec2 instance, for e.g "bastion-ec2-instance-intg" for the intg environment
* Click the Instance ID (it should be hyperlinked)
* Click the "Connect" button
* CLick "Session Manager" tab
* Click the "Connect" button
* In the console, type `cd /home/ssm-user` and click enter
* Then type `./connect.sh` and click enter

## Accessing database via your computer's CLI

### 1. Downloading and installing the Session Manager plugin
First you need to download and install the AWS Session Manager plugin

   * [Instructions for Mac (Step 1 to 3)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos)
   * [Instructions for Ubuntu (Step 1 to 2)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-debian)
   * [Instructions for Amazon Linux (Step 1 to 2)](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux)

You can check if it worked by running `session-manager-plugin`, which should show you the message

`The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.`

### 2. Obtaining the Instance ID for the Bastion instance

Next, you need to get the instance id for the bastion instance which can be found via command line or through the AWS console.

#### Via Command line (after you've updated your credentials)

   Run this `aws ec2 describe-instances`

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

#### Via Console

Alternatively, you can also get it from the console:

- In the search bar, type in "EC2" 
- Under "Resources", click "Instances"
- Find the bastion ec2 instance, for e.g "bastion-ec2-instance-intg" for the intg environment
- Copy the "InstanceId"

### 3. Connecting via Session Manager
Now you need to connect via the session manager by running the command

   `aws ssm start-session --target <the InstanceId you've copied>`
   (replacing the angle bracket parameter, with the InstanceId)

### 4. Starting PSQL

There is a script in the home directory which allows you to connect to postgres using IAM DB authentication
```
cd
./connect.sh
```

The script downloads the RDS public certificate if not already there, assumes a role which is allowed to connect to the database, generates a temporary password and uses this to connect to the database.

To quit PSQL, type `\q` and press Enter.

### 5. Setting up an ssh tunnel
If you want to connect to the database from your local machine, for example to use a locally installed application to connect, then you will need to set up an ssh tunnel.

This assumes you've added the ssh key when [creating the bastion](./applying-or-destroying-a-bastion-host.md#applying-a-bastion-host)

* Add this to your ssh config.
```
# SSH over Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```
* Get the instance id from the instances page in the console or by running
  `aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:Name,Values=bastion-ec2-instance-intg`
  
* Get the reader cluster endpoint. There are two ways:
  
  Select the reader cluster in the RDS Databases page in the console  
  Run `aws rds describe-db-cluster-endpoints | jq '.DBClusterEndpoints[] | select(.EndpointType == "READER") | .Endpoint'
  ` and select the endpoint for the consignment API.
* Run the ssh tunnel `ssh ec2-user@<instance_id> -N -L 65432:<db_cluster_endpoint>:5432`
* Update your hosts file. In *nix systems, this is in `/etc/hosts`, on Windows, it is in `C:\Windows\System32\drivers\etc\hosts` You will need to add an entry like

`127.0.0.1    <db_cluster_endpoint> `
* Get the password for the database. This password has a 15-minute expiry. If you want to connect again after that, you will need to generate a new password.

`aws rds generate-db-auth-token --profile <profile_name> --hostname <db_cluster_endpoint> --port 5432 --region eu-west-2 --username bastion_user`

* Download the rds certificate from https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

* Connect using the password and cluster endpoint

`psql  "host=<db_cluster_endpoint> port=65432 sslmode=verify-full sslrootcert=</location/of/rds-combined-ca-bundle.pem> dbname=consignmentapi user=bastion_user password=<generated_password>"`

### 6. Quitting Session Manager
 To quit Session Manager type `exit` and press Enter.
