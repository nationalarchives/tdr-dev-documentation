# 35. Metadata CSV Validation

**Date**: 2024-10-07

## Context

Digital assets sent to The National Archives (TNA) are transferred with associated metadata in CSV format. The entry point for digital assets to TNA will be through the services provided by the Digital Selection and Transfer team.

The structure and integrity of the CSV file is checked before the actual [data is validated](0034-metadata-validation.md) 

## Structure and integrity checks

1. **Virus check**: All files uploaded to TDR are checked for viruses using the virus check lambda
2. **[UTF-8](utf-8-validation)**: The CSV file must be UTF-8 format
3. **[Valid CSV file](valid-csv-file)**: Is it a CSV file
4. **[Required columns](required-columns)**: Certain columns are required (such as closure information columns) for all transfers

### UTF-8 Validation 

Technically it is not possible to [guarantee](https://www.quora.com/How-do-you-make-sure-a-file-is-UTF-8-encoded#:~:text=Technically%20you%20can't.,supplier%20how%20she%20encoded%20it) a file is UTF-8 encoded  
The tdr-draft-metadata-validator will use the presence of the BOM (Byte order mark) at the beginning of the file. This suggests the file was saved using software that encodes in UTF-8 such as **Microsoft Excel** 

### Valid CSV file

The tdr-draft-metadata-validator will try to load the file using the [CSV library](https://github.com/tototoshi/scala-csv).  
If it can load the file it will be treated as a valid CSV file

### Required columns

All files transferred through TDR require a certain amount of metadata. Required information includes closure information.  
The tdr-draft-metadata-validator will use a required schema in the [da-metadata-schema repo](https://github.com/nationalarchives/da-metadata-schema/tree/main/metadata-schema) to validate the required fields
