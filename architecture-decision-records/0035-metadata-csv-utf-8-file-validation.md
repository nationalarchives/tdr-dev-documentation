# 35. Metadata CSV file UTF-8 Validation

**Date**: 2024-10-21

## Context
When digital assets are transferred to The National Archives (TNA), they are accompanied by associated metadata in CSV format. The entry point for these digital assets is via services provided by the Digital Selection and Transfer team, and the assets are then passed on to downstream services within TNA for further processing.

To ensure data integrity and compatibility, the downstream consumers have requested that the metadata CSV files be encoded in UTF-8. Ensuring proper UTF-8 encoding is crucial to prevent issues like character corruption, which can occur if the file uses a different encoding format.

Although it's not programmatically possible to guarantee that a file has been encoded correctly in UTF-8, we can detect certain 'signatures' of UTF-8 encoding, such as the presence of a Byte Order Mark (BOM), which is sometimes added by applications like Microsoft Excel when saving CSV files in UTF-8.

Transferring bodies will be directed to use Microsoft Excel to prepare their metadata, as it offers the option to save CSV files in UTF-8 encoding. When this option is selected, a BOM (Byte Order Mark) is written to the beginning of the file (with the byte sequence `0xEF, 0xBB, 0xBF`).

The TDR (Transfer Digital Records) system must validate the metadata to ensure it has been saved in UTF-8 encoding, particularly by detecting the presence of the BOM.

## Decision
The UTF-8 validation for metadata CSV files will be implemented by checking for the presence of a BOM at the start of the file. This approach has been chosen for the following reasons:
- **Indication of UTF-8 Encoding:** The presence of the BOM strongly suggests that the file has been saved using the UTF-8 encoding option in Microsoft Excel, as recommended.
- **Efficiency:** It is a simple and efficient method to check only the first few bytes of the file, rather than analyzing the entire file.
- **Limitations of Other Applications:** Spreadsheet applications like LibreOffice (Linux) and Numbers (Mac) do not add a BOM when saving CSV files in UTF-8 encoding, and files saved by these applications will fail this validation.
- **Non-standard Applications:** CSV files edited with other text editors or tools that do not add a BOM will similarly fail the validation, as they might not follow the exact UTF-8 BOM signature expected.

## Other Options Considered
Other approaches, including more comprehensive methods of UTF-8 validation, were considered. For example, libraries like the [TNA utf8-validator](https://github.com/digital-preservation/utf8-validator) perform byte-level validation of UTF-8 encoding by checking for invalid byte sequences.

However, this library was not adopted because:
- It checks general UTF-8 compliance but does not specifically check for the BOM, which is the key indicator of UTF-8 encoding from Microsoft Excel, the recommended tool for creating metadata.
- This method would not specifically target the issue of ensuring metadata files have been saved in the expected UTF-8 format from Excel.
