# 34. Metadata Validation

**Date**: 2024-09-03

## Context

Metadata Validation for Digital Assets at The National Archives

Digital assets sent to The National Archives (TNA) are transferred with associated metadata. The entry point for digital assets to TNA will be through the services provided by the Digital Selection and Transfer team.

We need to ensure that the metadata associated with our digital assets is accurate and consistent. Incorrect metadata can lead to errors in data processing and analysis, affecting decision-making processes. Therefore, we need a robust mechanism to validate metadata and handle any errors that arise during the validation process.

## Decision Drivers

- **Accuracy**: Ensure that all metadata is precise and consistent with the defined standards.
- **Efficiency**: Provide automated processes to handle large volumes of metadata quickly and accurately.
- **Flexibility**: Offer manual validation options for exceptional cases and complex scenarios.
- **Usability**: Deliver clear, actionable error messages to facilitate quick resolution.
- **Scalability**: Ensure the solution can handle increasing volumes of digital assets and their metadata.
- **Openness**: All standards (schema) should be publicly available for use by any archives.

## Considered Options

1. **Manual Validation Only**: Rely solely on human intervention to check metadata for accuracy.
2. **Automated Validation Only**: Implement code to automatically validate metadata without manual intervention.
3. **Hybrid Approach**: Combine both manual and automated validation processes to leverage the strengths of each method.

## Decision Outcome

We decided to adopt a Hybrid Approach for metadata validation, combining both manual and automated processes. This approach was chosen because:

- Automated validation efficiently handles large volumes of metadata, reducing the risk of human error.
- Manual validation provides flexibility to address complex and exceptional cases that automated processes might not handle well.
- Clear error messages and guidelines for resolution enhance usability and help stakeholders quickly address issues.
- Scalability ensures that our validation processes can grow with the volume of digital assets.

## Validation Process

### Automated Validation

- **Schema Validation**: Ensure metadata conforms to the predefined schemas (individual elements).
- **File Validation**: Is CSV UTF8 and a CSV
- **Content Validation**: Check the accuracy and consistency of metadata values.
- **Dependency Validation**: Automatically verify relationships and dependencies between metadata elements (partly schema-driven). Examples include closure data.

### Manual Validation (Out of Scope)

### Error Handling

The automated validation API will return the errors.

- **Save Errors**: The TDR validation process (that will invoke the `tdr-metadata-validation` API) must save the errors in a format that can be programmatically retrieved and provided to the user. The first solution will be to save the errors in JSON format to S3. Versioning will be set for the S3 bucket so the history of the errors can be seen if required. (TODO: Decide if errors need to be processed/stored for analytics and other reasons.)
- **Provide Errors to the User**: The user must be able to view errors detected in the automated process so they can fix them and submit new metadata.

## Transfer Digital Records Draft Metadata

Transferring bodies using TDR to transfer records will supply metadata in a CSV file. The format of the CSV file can be determined from the base schema.

```json
"date_last_modified": {
  "type": "string",
  "format": "date",
  "propertyType": "System",
  "alternateKeys": [
    {
      "tdrFileHeader": "Date last modified",
      "tdrDataLoadHeader": "ClientSideFileLastModifiedDate"
    }
  ]
}
```
To supply `"date_last_modified"`, the CSV column header would be `"Date last modified"` (`tdrFileHeader`).

### Example CSV headers include:

- Closure Information
- FOI Exemption Code
- Closure Start Date
- Date of FOI Decision

See closure schema (WIP).

### Additional Metadata Fields:

- Language
- Is the description sensitive for the public?
- Alternative description
- Description
- ...and more.

## Implementation

### Partial CSV Structure

Here is the tabular data from an example metadata CSV:

| Filepath            | Filename     | Date last modified | Closure status | Closure Start Date | FOI exemption code | Language | UUID                                   |
|---------------------|--------------|--------------------|----------------|--------------------|--------------------|----------|----------------------------------------|
| test/metadata.json  | metadata.json| 2024-07-31         | Open           |                    | 27\|35(1)(2)        | English  | 7144708b-c246-4cf6-9c8f-9bf4ea7bd488   |

### Mapping CSV Header to Value

Mapping of CSV header to value:

- `Filepath` -> `test/metadata.json`
- `Filename` -> `metadata.json`
- `Date last modified` -> `2024-07-31`
- `Closure status` -> `Open`
- `Closure Start Date` -> ``
- `FOI exemption code` -> `27|35(1)(2)`
- `Language` -> `English`
- `UUID` -> `7144708b-c246-4cf6-9c8f-9bf4ea7bd488`

### Mapping with Property Names from `tdrFileHeader` to Validation Key

- `file_path` -> `test/metadata.json`
- `file_name` -> `metadata.json`
- `date_last_modified` -> `2024-07-31`
- `closure_type` -> `Open`
- `closure_start_date` -> ``
- `foi_exemption_code` -> `27|35(1)(2)`
- `language` -> `English`
- `UUID` -> `7144708b-c246-4cf6-9c8f-9bf4ea7bd488`

### Conversion to JSON

The above mapping can be represented in JSON format as follows:

```json
{
  "file_path": "test/metadata.json",
  "file_name": "metadata.json",
  "date_last_modified": "2024-07-31",
  "closure_type": "Open",
  "closure_start_date": null,
  "foi_exemption_code": ["27", "35(1)(2)"],
  "language": "English",
  "UUID": "7144708b-c246-4cf6-9c8f-9bf4ea7bd488"
}
```
## JSON Schema Validation and Automated Processes

### JSON Schema Validation

The JSON can now be validated against the schema.

### Automated Processes

1. **CSV to JSON Conversion**: Develop code to convert the provided CSV file to JSON format.
2. **JSON Schema Validation**: Integrate a JSON schema validator library to validate the metadata in the `tdr-metadata-validation`.
3. **Error Processing**: Develop code to process and persist validation errors.
4. **TDR Service Integration**: 
   - Integrate with the TDR service.
   - Invoke the `tdr-metadata-validation` interface with the TDR service.
5. **Error Download**: Provide a method to allow users to download the errors.

### Validation Error Structure

Validation of the data can be performed by different processes. The interface to metadata validation will return a collection of `ValidationError`:

```scala
case class ValidationError(validationProcess: ValidationProcess, property: String, errorKey: String, message:Option[String])

object ValidationProcess extends Enumeration {
  type ValidationProcess = Value
  val SCHEMA_BASE, SCHEMA_CLOSURE_CLOSED, SCHEMA_CLOSURE_OPEN, FILE_CHECK = Value
}
```
**validationProcess**: Indicates the validation process used.

**property**: the property name from the schema being evaluated .

**errorKey**: A key used to indicate type of error

## Error Conversion and Storage

To process and/or store these errors, they need to be converted into a format (JSON expected) that can be stored and then provided to the digital transfer in a user-friendly way.

### JSON response examples:
- Schema Validation
```{
  "consignmentId": "22dbf727-3410-4e47-8e16-fa1d51904950",
  "date": "2024-12-12",
  "fileError": "SCHEMA_VALIDATION",
  "validationErrors": [
    {
      "assetId": "7fc876d7-bab0-493c-b685-5e8b5affbb2f",
      "errors": [
        {
          "validationProcess": "SCHEMA_CLOSURE",
          "property": "FOI exemption code",
          "errorKey": "enum",
          "message": "This must be a pipe delimited list of valid FOI codes, (eg. 31|33). Please see the guidance for more detail on valid codes"
        },
        {
          "validationProcess": "SCHEMA_BASE",
          "property": "date_last_modified",
          "errorKey": "format.date",
          "message": "Must be a date in the format yyyy-mm-dd"
        }
      ],
      "data": [
        {
          "name": "FOI exemption code",
          "value": "eee"
        },
        {
          "name": "Date last modified",
          "value": "eee"
        },
        {
          "name": "Filepath",
          "value": "/gggg/jj"
        },
      ]
    }
  ]
}
```
- UTF-8 Error
```
{
  "consignmentId": "22dbf727-3410-4e47-8e16-fa1d51904950",
  "date": "2024-12-12",
  "fileError": "UTF-8",
  "validationErrors": [
    {
      "assetId": "22dbf727-3410-4e47-8e16-fa1d51904950",
      "errors": [
        {
          "validationProcess": "FILE_VALIDATION",
          "property": "draftmetadata.csv",
          "errorKey": "UTF_8",
          "message": "The Metadata csv must be saved as UTF-8"
        }
      ]
    }
  ]
}
```
- Required columns
```
{
  "consignmentId": "22dbf727-3410-4e47-8e16-fa1d51904950",
  "date": "2024-12-12",
  "fileError": "SCHEMA_REQUIRED"
  "validationErrors": [
    {
      "assetId": "22dbf727-3410-4e47-8e16-fa1d51904950",
      "errors": [
        {
          "validationProcess": "SCHEMA_REQUIRED",
          "property": "FOI decision asserted",
          "errorKey": "required",
          "message": "FOI decision asserted"
        }
      ]
    }
  }
}
```

```consignmentId```: An identifier used to determine the csv file validated    
```date```: Date of validation  
```fileError```: Type of errors. There are several steps in the validation. When errors are found further validation stops
- ```UTF-8```
- ```SCHEMA_VALIDATION```
- ```SCHEMA_REQUIRED```
- ```.....```  

```validationErrors```: List of errors
```
{
      "assetId": "7fc876d7-bab0-493c-b685-5e8b5affbb2f",
      "errors": [
        { ....
       
```
```assetId```: Link a record to the errors (row in csv or file)  
```errors```
```
{
     "validationProcess": "SCHEMA_CLOSURE",
     "property": "FOI exemption code",
     "errorKey": "enum",
     "message": "SCHEMA_CLOSURE.foi_exmption_code.enum"
 }
 ```
- ```validationProcess```: [Automated Validation](#automated-validation)
- ```property```: The property key of data passed for validation
- ```errorKey```: key to indicate error
- ```message``` : User friendly message

## User Friendly Error Messages

A message properties file will be used to define the user-friendly message returned to the user.

Each error will have a key in the following format:

```
{validationProcess}.{property}.{errorKey}
```  
- ```property``` is the value in the base schema
### Key example
```SCHEMA_BASE.foi_exemption_code.enum```  

### Properties File Example
```SCHEMA_BASE.foi_exemption_code.enum=An invalid FOI exemption code has been used.```

## User-Friendly Error Messages

To provide clear and actionable feedback to the user, the error messages should be:

- **Clarity**: Clear and specific, avoiding technical jargon.
- **Actionable**: Providing guidance on how to correct the error.
- **Contextual**: Including the erroneous value and the expected value or format.
- **Consistent**: Using a consistent format for all error messages to help users quickly identify and resolve issues.

By adhering to these guidelines, metadata validation ensures robust data integrity and improves user experience.
