#Accessing an environment's database

Connecting to a database must be done through an [AWS Bastion host](./applying-or-destroying-a-bastion-host.md), below are the steps detailing how to do this

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

###Via Console

Alternatively, you can also get it from the console:

- In the search bar, type in "EC2" 
- Under "Resources", click "Instances"
- Find the bastion ec2 instance, for e.g "bastion-ec2-instance-intg" for the intg environment
- Copy the "InstanceId"

##3. Connecting via Session Manager
Now you need to connect via the session manager by running the command

   `aws ssm start-session --target <the InstanceId you've copied>`
   (replacing the angle bracket parameter, with the InstanceId)

##4. Starting PSQL

There is a script in the home directory which allows you to connect to postgres using IAM DB authentication
```
cd
./connect.sh
```

The script downloads the RDS public certificate if not already there, assumes a role which is allowed to connect to the database, generates a temporary password and uses this to connect to the database. 

##5. Setting up an ssh tunnel
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

* Get the database endpoint. There are three ways:

  You can get this from the AWS console by going to RDS, click DB Instances, choose the reader instance from the consignment api database and copy the endpoint.

  You can call `aws rds describe-db-instances` and look for a field called `Address` for the consignment api.

  You can open the `/home/ssm-user/connech.sh` script on the bastion host and the endpoint is in there assigned to the RDSHOST variable.
* Run the ssh tunnel

`ssh ec2-user@instance_id -N -L 65432:db_host_name:5432`

* Get the cluster endpoint. There are two ways:
  Select the cluster in the RDS Databases page in the console  
  Run `aws rds describe-db-cluster-endpoints | jq '.DBClusterEndpoints[] | select(.EndpointType == "READER") | .Endpoint'
  ` and select the endpoint for the consginment API.
* Update your hosts file. In *nix systems, this is in `/etc/hosts`, on Windows, it is in `C:\Windows\System32\drivers\etc\hosts` You will need to add an entry like

`127.0.0.1    cluster_endpoint `
* Get the password for the database. This password has a 15 minute expiry. If you want to connect again after that, you will need to generate a new password.

`aws rds generate-db-auth-token --profile integration --hostname $RDSHOST --port 5432 --region eu-west-2 --username bastion_user`

* Download the rds certificate from https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

* Connect using the password and cluster endpoint

`psql  "host=cluster_endpoint port=65432 sslmode=verify-full sslrootcert=/location/of/rds-combined-ca-bundle.pem dbname=consignmentapi user=bastion_user password=generated_password"`
