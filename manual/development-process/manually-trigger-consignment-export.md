# Manually Trigger Consignment Export Step Function

**NOTE**: Before manually triggering a **judgment** consignment export double check with the Find Case Law (FCL) team that the user has not re-attempted the transfer to prevent duplicate judgments being published

In some circumstances it may be necessary to manually trigger a consignment export, for example:
* Consignment export failure;
* Legitimate request from another Digital Archiving service for a re-export

## Use AWS Console to manually execute Consignment Export Step Function
1. Retrieve the relevant consignment id for the consignment to trigger the export for
2. Log into the relevant AWS account
3. Go to the TDRConsignmentExport{env} step function
4. Click `Start Execution` and add the relevant json into the dialog box:
    ```
   {
      "ConsignmentId": "{consignment id for consignment}"
   }
   ```
5. Enter the a name for the new execution into the dialog box in the following form: `{initials}-{consignment id for consignment}`
6. Click `Start execution`

## Use AWS CLI to manually execute Consignment Export Step Function
1. Retrieve the relevant consignment id for the consignment to trigger the export for
2. Ensure have relevant credentials set to execute the step function
3. Run the following command:
    ```
   $ aws cli start-execution --state-machine-arn {arn of the step function} \
      --name {initials}-{consignment id for consignment} \
      --input "input": "{\"ConsignmentId\" : \"{consignment id for consignment}\"}"
   ```

Full details of the `start-execution` command can be found here: https://docs.aws.amazon.com/cli/latest/reference/stepfunctions/start-execution.html
