# 33. Handling SharePoint Metadata

**Date:** 2024-XX-XX

## Nomenclature

The following nomenclature is used in this document:
* `Custom metadata`: any metadata property that is not one of TNA's defined metadata properties
* `System metadata`: any metadata property that comes from the source system itself, eg the date the record was last modified
* `Source system`: the system where the transfer data comes from, for example network drive, SharePoint, Google Drive etc

## Context

TDR will be receiving transfers from SharePoint, including SharePoint metadata.

SharePoint supports over 60 system metadata properties, along with users being able to define their own metadata properties within SharePoint.

TDR is required to capture this metadata to ensure the accuracy of the record.

This means TDR needs to adjust its processing and storage of the metadata to meet the needs of SharePoint transfers along with considering the needs of other source systems, such a Google Drive

### Considerations

* SharePoint system metadata properties may change over time. For example new properties maybe added, or existing properties maybe renamed
* SharePoint transfers will contain large amounts of custom metadata
* Decisions should also work for other source systems apart from SharePoint, for example Google Drive
* Custom metadata also comes from different transfers apart from SharePoint

## Decisions

The approached outlined below should allow TDR to capture SharePoint metadata and output it in a form that can be used by downstream services, whilst still maintaining existing processes.

It should also be extensible to other source systems such as Google Drive

### System Metadata
* Map any SharePoint system metadata to TNA's defined metadata properties where possible
* Any SharePoint system metadata properties that TNA wants and that cannot be mapped should be added to TNA's defined metadata properties
* Non-mapped properties should be identified in the Database as specifically relating to SharePoint
* Non-mapped properties will be outputted in a separate CSV file in the TDR Bagit package identifying the source as SharePoint, for example: `sharepoint-metadata.csv`

#### Changes to system metadata

Should a change occur to system metadata, for example a metadata property is re-named this re-named metadata property would be captured as custom metadata.

So TDR would still capture it but it would be classified differently.

### Custom Metadata
* To be stored separately from TNA's defined metadata properties. For example in a different Database table
* Any metadata about the custom metadata properties from the source to be stored separately. For example in a Database table
* Custom metadata properties will be outputted as an aggregated `json` file (ie single file per bagit package) in the TDR Bagit package, for example: `custom-metadata.json`
* Metadata about the custom metadata properties will be outputted as an aggregated `json` file (ie single file per bagit) in the TDR Bagit package, for example: `custom-properties-metadata.json`

### Example Bagit Package Structure

-- `data` (existing)

---- `{record digital objects}` (existing)

-- `bag-info.txt` (existing)

-- `bagit.txt` (existing)

-- `file-av.csv` (existing)

-- `file-ffid.csv` (existing)

-- `file-metadata.csv` (existing)

-- `sharepoint-metadata.csv` (new)

-- `custom-metadata.json` (new)

-- `custom-properties-metadata.json` (new)

-- `manifest-sha256.txt` (existing)

-- `tagmanifest-sha256.txt` (existing)
