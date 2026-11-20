# Lambda runtimes

## Updating Lambda Java Runtime

TDR Java Lambda build workflows and AWS Lambda runtimes must use compatible
Java versions. The version is defined centrally in `tdr-configurations` and
shared with Terraform and the Lambda repository's GitHub Actions workflows.
GitHub Actions reads the version from the repository variable `JAVA_RUNTIME`.

### Change a Lambda's Java version

Use these steps when upgrading or changing the Java version for an existing
Lambda. First identify its configuration key (for example, `api-update-v2`)
and check that the target Java version is supported by AWS Lambda and the
Lambda's build tools.

1. In [tdr-configurations][configurations], change the Lambda's value in the
  `lambda_java_runtimes` output in `terraform/runtimes.tf`. The value is the
  Java version number as a string, without the `java` prefix. For example:

   ```hcl
   output "lambda_java_runtimes" {
    description = "Java runtime versions used to build and run Lambda functions"
    value = {
     api-update-v2 = "17"
     }
   }
   ```

2. Check that [tdr-terraform-github][terraform-github] and
  [tdr-terraform-environments][terraform-environments] are using the updated
  `tdr-configurations` revision.

3. Reapply [tdr-terraform-github][terraform-github] after updating its
   `tdr-configurations` revision. This refreshes the `JAVA_RUNTIME` repository
   variable with the new value.

4. Confirm that the GitHub repository variable `JAVA_RUNTIME` is sourced from
  the shared output in `tdr-terraform-github`, rather than set to a literal
  version. Applying this Terraform configuration updates the variable used
  by the Lambda's workflows.

5. Confirm that the Lambda runtime in `tdr-terraform-environments` is sourced
  from the same output. It should follow this pattern:

   ```hcl
   runtime = "java${module.global_parameters.lambda_java_runtimes["api-update-v2"]}"
   ```

  Applying this Terraform configuration updates the AWS Lambda runtime.

6. Confirm that the Lambda's build and test workflows use the repository
  variable for the reusable workflow's `java-version` input, not a hardcoded
  version or a secret:
  
   ```yaml
   with:
     java-version: ${{ vars.JAVA_RUNTIME }}
   ```

  If a workflow still uses a literal version, change it to this variable.

[configurations]: https://github.com/nationalarchives/tdr-configurations/tree/master/terraform
[terraform-github]: https://github.com/nationalarchives/tdr-terraform-github
[terraform-environments]: https://github.com/nationalarchives/tdr-terraform-environments# Lambda runtimes

## Updating Lambda Java Runtime

TDR Java Lambda build workflows and AWS Lambda runtimes must use compatible
Java versions. The version is defined centrally in `tdr-configurations` and
shared with Terraform and the Lambda repository's GitHub Actions workflows.
GitHub Actions reads the version from the repository variable `JAVA_RUNTIME`.

### Change a Lambda's Java version

Use these steps when upgrading or changing the Java version for an existing
Lambda. First identify its configuration key (for example, `api-update-v2`)
and check that the target Java version is supported by AWS Lambda and the
Lambda's build tools.

1. In [tdr-configurations][configurations], change the Lambda's value in the
  `lambda_java_runtimes` output in `terraform/runtimes.tf`. The value is the
  Java version number as a string, without the `java` prefix. For example:

   ```hcl
   output "lambda_java_runtimes" {
    description = "Java runtime versions used to build and run Lambda functions"
    value = {
     api-update-v2 = "17"
     }
   }
   ```

2. Check that [tdr-terraform-github][terraform-github] and
  [tdr-terraform-environments][terraform-environments] are using the updated
  `tdr-configurations` revision.

3. Reapply [tdr-terraform-github][terraform-github] after updating its
   `tdr-configurations` revision. This refreshes the `JAVA_RUNTIME` repository
   variable with the new value.

4. Confirm that the GitHub repository variable `JAVA_RUNTIME` is sourced from
  the shared output in `tdr-terraform-github`, rather than set to a literal
  version. Applying this Terraform configuration updates the variable used
  by the Lambda's workflows.

5. Confirm that the Lambda runtime in `tdr-terraform-environments` is sourced
  from the same output. It should follow this pattern:

   ```hcl
   runtime = "java${module.global_parameters.lambda_java_runtimes["api-update-v2"]}"
   ```

  Applying this Terraform configuration updates the AWS Lambda runtime.

6. Confirm that the Lambda's build and test workflows use the repository
  variable for the reusable workflow's `java-version` input, not a hardcoded
  version or a secret:
  
   ```yaml
   with:
     java-version: ${{ vars.JAVA_RUNTIME }}
   ```

  If a workflow still uses a literal version, change it to this variable.

[configurations]: https://github.com/nationalarchives/tdr-configurations/tree/master/terraform
[terraform-github]: https://github.com/nationalarchives/tdr-terraform-github
[terraform-environments]: https://github.com/nationalarchives/tdr-terraform-environments