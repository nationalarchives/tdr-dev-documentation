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

Technically it is not possible to [guarantee](https://www.quora.com/How-do-you-make-sure-a-file-is-UTF-8-encoded#:~:text=Technically%20you%20can't.,supplier%20how%20she%20encoded%20it) a file is UTF-8 encoded.
- "Technically you can’t. Files containing characters may be encoded in a wide variety of different ways, of which plain ASCIII and UTF-8 are just 2 encodings.
- Basically to read a text file given to you by another party, the *only* reliable way to know its encoding is to ask the supplier how she encoded it. Absent that, you simply don’t know what encoding it has."

### UTF-8 'validation' options
- Check leading BOM 'EF BB BF'
- Third party libraries, such as [TNA utf8-validator](https://github.com/digital-preservation/utf8-validator)
 
The metadata csv files are prepared by the transferring body, and it is expected **Microsoft Excel** will be used and users can be required to save with the UTF-8 option.  
Files stored in this manner will add the BOM

The tdr-draft-metadata-validator will use the presence of the BOM (Byte order mark) at the beginning of the file. This indicates the file have been created with **Microsoft Excel** and will be UTF-8.  
This method is restrictive as other spreadsheet software such as LibreOffice (Linux) and Numbers (Mac) do not add the BOM
