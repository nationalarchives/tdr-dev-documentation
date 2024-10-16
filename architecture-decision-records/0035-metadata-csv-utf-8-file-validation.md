# 35. Metadata CSV file UTF-8 Validation

**Date**: 2024-10-07

## Context

Digital assets sent to The National Archives (TNA) are transferred with associated metadata in CSV format. The entry point for digital assets to TNA will be through the services provided by the Digital Selection and Transfer team.

The structure and integrity of the CSV file is checked before the actual [data is validated](0034-metadata-validation.md) 

## Structure and integrity checks

1. **Virus check**: All files uploaded to TDR are checked for viruses using the virus check lambda
2. **[UTF-8](utf-8-validation)**: The CSV file must be UTF-8 format

### UTF-8 'validation' options
- Check leading BOM 'EF BB BF'
- Third party libraries, such as [TNA utf8-validator](https://github.com/digital-preservation/utf8-validator)
 
The metadata csv files are prepared by the transferring body, and it is expected **Microsoft Excel** will be used and users can be required to save with the UTF-8 option.  
Files stored in this manner will add the BOM

The tdr-draft-metadata-validator will use the presence of the BOM (Byte order mark) at the beginning of the file. This indicates the file may have been created with **Microsoft Excel** and explicitly saved as UTF-8. This is a simple and fast check that only for the first three bytes 'EF BB BF'  
This method is restrictive as other spreadsheet software such as LibreOffice (Linux) and Numbers (Mac) do not add the BOM

TNA CSV validator uses TNA utf8-validator library. This library checks the byte sequence and invalid single bytes. It does not check the BOM that suggests a file saved explicitly saved as UTF-8 from Microsoft Excel

Whilst TDR requires the user to save the metadata csv in UTF-8 format from **Microsoft Excel** the BOM validation method will be used and no further UTF-8 checks made


