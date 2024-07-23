# Remove contaminated files from the TDR system

This guides the steps necessary to remove files from the TDR database and S3 buckets.

## SSH tunneling to connect bastion from your local machine - (required to delete from intg/staging database)

1. Install the latest aws cli on your machine.
2. Create an AWS CLI profile
   ```
   aws configure sso
   aws sso login --profile tdr-integration ( change to the profile you created)
   ```
3. Add your ssh key to the bastion
    - sudo su ec2-user
    - cd .ssh
    - nano authorised_key
4. On your machine add a line to your .ssh config file
    ```
     # SSH over Session Manager
     host i-* mi-*
     ProxyCommand aws ssm start-session --profile tdr-integration --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'
    ```
5. On your machine add the following to your hosts file:</br>
   $ nano /etc/hosts </br>
   `127.0.0.1 consignmentapi-wws3yt5xqi.cben4drnnalt.eu-west-2.rds.amazonaws.com`
6. Create the tunnel (DON't FORGET TO REPLACE INSTANCE ID WITH NEW ID)
   ```
    ssh ec2-user@i-0403fd17c28c70d46 -N -L 65432:consignmentapi-wws3yt5xqi.cben4drnnalt.eu-west-2.rds.amazonaws.com:5432
   ```
7. Start a new window to get the password for `bastion_user` or `migrations_user` or `consignment_api_user`
   ```
    aws rds generate-db-auth-token --hostname consignmentapi-wws3yt5xqi.cben4drnnalt.eu-west-2.rds.amazonaws.com --port 5432 --region eu-west-2 --username migrations_user --profile tdr-integration
   ```
8. Open SQL workbench client
    - Add URL - `jdbc:postgresql://consignmentapi-wws3yt5xqi.cben4drnnalt.eu-west-2.rds.amazonaws.com:65432/consignmentapi`
    - Username - migrations_user
    - Password - <Use the password which we got from step 7>

## Remove from the database
1. Connect the bastion using the above steps
2. If you have a checksum then use the below query to find all the affected consignments:
    ```
        select DISTINCT c."ConsignmentId", c."ConsignmentReference", c."UserId" from "Consignment" c join "File" f on c."ConsignmentId" = f."ConsignmentId"  join "FileMetadata" fm on f."FileId" = fm."FileId" where "Value" in ('REPLACE IT WITH CHECKUM VALUES');
    ``` 
   Or if you know the file id of the contaminated file then first find the checksum and then use it to find all the affected files.</br>
   **Once you get the results, save them in a notepad because you need these details to delete files from the S3 buckets**

3. Use the following sequence to delete all the references of affected consignments from the database:

   | Table               | Query to delete                                                                                                                                                                                           |
       |---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
   | AVMetadata          | `delete from "AVMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in ('CONSIGNMENT IDs'));`                                                                                  |
   | FFIDMetadataMatches | `delete from "FFIDMetadataMatches" where "FFIDMetadataId" in (select "FFIDMetadataId" from "FFIDMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in ('CONSIGNMENT IDs')));` |
   | FFIDMetadata        | `delete from "FFIDMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in ('CONSIGNMENT IDs'));`                                                                                |
   | FileMetadata        | `delete from "FileMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in ('CONSIGNMENT IDs'));`                                                                                |
   | FileStatus          | `delete from "FileStatus" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in ('CONSIGNMENT IDs'));`                                                                                  |
   | File                | `delete from "File" where "ConsignmentId" in ('CONSIGNMENT IDs');`                                                                                                                                        |
   | ConsignmentStatus   | `delete from "ConsignmentStatus" where "ConsignmentId" in ('CONSIGNMENT IDs');`                                                                                                                           |
   | ConsignmentMetadata | `delete from "ConsignmentMetadata" where "ConsignmentId" in ('CONSIGNMENT IDs');`                                                                                                                         |
   | Consignment         | `delete from "Consignment" where "ConsignmentId" in ('CONSIGNMENT IDs');`                                                                                                                                 |


## Remove from the S3 buckets
1. **tdr-consignment-export-{intg/staging}**: Run below shell scripts to delete permanently files from the bucket:
    ```
    #!/bin/bash
    
    # Add consignment references here (Use white space to add multiple references)
    refs="TDR-XXX-NNN TDR-XXX-ABC"
    bucket=tdr-backend-checks-{env}
    
    for ref in $refs
    do
        echo $ref
        versions=$(aws s3api list-object-versions --bucket $bucket --prefix $ref --query 'Versions[].{Key:Key,VersionId:VersionId}' --profile tdr-integration --output json)
    
        echo "$versions" | jq -c '.[]' | while read -r version; do
          Key=$(echo "$version" | jq -r '.Key')
          VersionId=$(echo "$version" | jq -r '.VersionId')
          echo "$Key-$VersionId"
          aws s3api delete-object --bucket $bucket --key $Key --version-id $VersionId --profile tdr-integration
        done
    done
    ```
2. **tdr-upload-files-cloudfront-dirty-{intg/staging}**: Run below shell scripts to delete permanently files from the bucket:
    ```
    #!/bin/bash
    
    # Add user ids here (Use white space to add multiple ids)
    refs="30307a5c-83ed-407a-aef8-1fb6e0"
    bucket=tdr-upload-files-cloudfront-dirty-{env}
    
    for ref in $refs
    do
        echo $ref
        versions=$(aws s3api list-object-versions --bucket $bucket --prefix $ref --query 'Versions[].{Key:Key,VersionId:VersionId}' --profile tdr-integration --output json)
    
        echo "$versions" | jq -c '.[]' | while read -r version; do
          Key=$(echo "$version" | jq -r '.Key')
          VersionId=$(echo "$version" | jq -r '.VersionId')
          echo "$Key-$VersionId"
          aws s3api delete-object --bucket $bucket --key $Key --version-id $VersionId --profile tdr-integration
        done
    done
    ```
3. **tdr-upload-files-{intg/staging}**: Run below shell scripts to delete permanently files from the bucket:
    ```
    #!/bin/bash
    
    # Add consignment ids here (Use white space to add multiple ids)
    refs="30307a5c-83ed-407a-aef8-1fb6e0"
    bucket=tdr-upload-files-{env}
    
    for ref in $refs
    do
        echo $ref
        versions=$(aws s3api list-object-versions --bucket $bucket --prefix $ref --query 'Versions[].{Key:Key,VersionId:VersionId}' --profile tdr-integration --output json)
    
        echo "$versions" | jq -c '.[]' | while read -r version; do
          Key=$(echo "$version" | jq -r '.Key')
          VersionId=$(echo "$version" | jq -r '.VersionId')
          echo "$Key-$VersionId"
          aws s3api delete-object --bucket $bucket --key $Key --version-id $VersionId --profile tdr-integration
        done
    done
    ```
4. **tdr-backend-checks-{intg/staging}**: Run below shell scripts to delete permanently files from the bucket:
    ```
    #!/bin/bash
    
    # Add consignment ids here (Use white space to add multiple ids)
    refs="30307a5c-83ed-407a-aef8-1fb6e0"
    bucket=tdr-backend-checks-{env}
    
    for ref in $refs
    do
        echo $ref
        versions=$(aws s3api list-object-versions --bucket $bucket --prefix $ref --query 'Versions[].{Key:Key,VersionId:VersionId}' --profile tdr-integration --output json)
    
        echo "$versions" | jq -c '.[]' | while read -r version; do
          Key=$(echo "$version" | jq -r '.Key')
          VersionId=$(echo "$version" | jq -r '.VersionId')
          echo "$Key-$VersionId"
          aws s3api delete-object --bucket $bucket --key $Key --version-id $VersionId --profile tdr-integration
        done
    done
    ```
4. **tdr-upload-files-quarantine-{intg/staging}**: Run below shell scripts to delete permanently files from the bucket:
    ```
    #!/bin/bash
    
    # Add consignment ids here (Use white space to add multiple ids)
    refs="30307a5c-83ed-407a-aef8-1fb6e0"
    bucket=tdr-upload-files-quarantine-{env}
    
    for ref in $refs
    do
        echo $ref
        versions=$(aws s3api list-object-versions --bucket $bucket --prefix $ref --query 'Versions[].{Key:Key,VersionId:VersionId}' --profile tdr-integration --output json)
    
        echo "$versions" | jq -c '.[]' | while read -r version; do
          Key=$(echo "$version" | jq -r '.Key')
          VersionId=$(echo "$version" | jq -r '.VersionId')
          echo "$Key-$VersionId"
          aws s3api delete-object --bucket $bucket --key $Key --version-id $VersionId --profile tdr-integration
        done
    done
    ```