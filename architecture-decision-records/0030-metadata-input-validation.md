# 4. Metadata input validation

**Date**: 2023-08-14

## Context

TDR has a feature to add additional metadata by submitting the form. When the user submits the form, we validate the input data
and show an error on the page if the input data is incorrect or if everything is correct then we add the data into the database.
Now, we will be adding another feature to add metadata by uploading a CSV file.
So, again we need to validate the CSV file and if everything is correct then add the data into the database otherwise show an error.

To avoid multiple validation, we thought to have a common validation for form and CSV file both.
We looked into the options of creating a validation library or lambda or keeping the logic in the frontend only.


## Decision

Use a validation library.

We found that a library will be very useful for form and CSV file validation. We will send input data (form and CSV data) and metadata criteria,
it will then check data against the metadata criteria, and if the data is invalid then will return error codes to generate error messages
as per source.

The other benefit is that we can use this library to validate the input data in [Consignment API][consignment-api] too as we are validating on API while
updating the additional metadata.


[consignment-api]: https://github.com/nationalarchives/tdr-consignment-api
